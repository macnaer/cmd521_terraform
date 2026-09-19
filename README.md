# Terraform — AWS EC2 + S3 Static Website

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3-purple)
![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20S3-orange)
![License](https://img.shields.io/badge/License-MIT-green)

Один Terraform root-конфіг, два незалежних модулі:

- **`modules/ec2`** — два EC2 інстанси (Ubuntu + Amazon Linux) зі спільним
  Security Group (SSH/HTTP/ICMP).
- **`modules/s3-static-website`** — публічний S3 bucket з website hosting,
  автоматично завантажує весь вміст `files/Web/`.

Регіон за замовчуванням: **`eu-north-1`** (Stockholm).

---

## 1. Передумови

| Інструмент | Версія | Перевірка |
|------------|--------|-----------|
| Terraform  | ≥ 1.3  | `terraform version` |
| AWS акк.   | права на EC2 + S3 | — |
| EC2 key pair | існуючий key pair | `aws ec2 describe-key-pairs` (за замовч. `Stockholm_3`) |

---

## 2. Підготовка credentials

```powershell
# з кореня проєкту
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

У `terraform.tfvars` впишіть:

```hcl
aws_access_key = "AKIA..."
aws_secret_key = "QwK..."
```

> Файл `terraform.tfvars` доданий у `.gitignore` — не комітиться.

За потреби перевизначте будь-яку змінну тут же, наприклад:

```hcl
s3_bucket_name        = "my-unique-bucket-name"
aws_key_name          = "my-keypair"
s3_versioning_enabled = false
```

---

## 3. Стандартний workflow

```powershell
# 1) відформатувати всі .tf файли (модулі + root)
terraform fmt -recursive

# 2) завантажити провайдерів та ініціалізувати модулі
terraform init

# 3) перевірити синтаксис (без звернення до AWS)
terraform validate

# 4) preview — показує що буде створено/змінено/знищено
terraform plan

# 5) застосувати (після ще одного "yes")
terraform apply

# 6) подивитися outputs (зокрема URL сайту)
terraform output
terraform output s3_website_url

# 7) зруйнувати все
terraform destroy
```

---

## 4. Архітектура

```
┌──────────────────────── AWS eu-north-1 ────────────────────────┐
│                                                                │
│  ┌────── module "ec2" ───────┐    ┌── module "s3_static_website" ─┐
│  │ SG_Terraform             │    │ Bucket: terraform-static-...   │
│  │  ingress: ssh/http/icmp  │    │  • website endpoint (HTTP)     │
│  │  egress:  all            │    │  • public GetObject policy     │
│  │                          │    │  • versioning + AES256 SSE     │
│  │  ┌── Ubuntu t3.small ──┐ │    │  • uploaded files/Web/*        │
│  │  └── Amazon Linux ─────┘ │    │  • synthetic error.html        │
│  └──────────────────────────┘    └───────────────────────────────┘
└────────────────────────────────────────────────────────────────┘
```

---

## 5. Як знати, який модуль виконується

Кожен ресурс Terraform має **адресу**, що починається з імені модуля. Це
найнадійніший спосіб побачити, що і звідки створюється/змінюється/знищується.

### 5.1. Префікси адрес (state та plan)

| Префікс адреси | Модуль | Що створює |
|----------------|--------|-----------|
| `module.ec2.*`                    | `modules/ec2` | 2× EC2 + SG + 4 SG rules |
| `module.s3_static_website.*`      | `modules/s3-static-website` | 1× bucket + ~10 bucket-resources + ~50 файлів |

Приклад з `terraform plan`:

```
  # module.ec2.aws_instance.primary                will be created
  # module.ec2.aws_security_group.this             will be created
  # module.s3_static_website.aws_s3_bucket.this    will be created
  # module.s3_static_website.aws_s3_object.files["index.html"]  will be created
```

### 5.2. Корисні команди для інспекції

```powershell
# Усі ресурси з префіксом модуля
terraform state list
terraform state list | Select-String "module\.ec2"
terraform state list | Select-String "module\.s3_static_website"

# Скільки ресурсів у кожному модулі
terraform state list | Select-String "module\.ec2"                  | Measure-Object | Select-Object -ExpandProperty Count
terraform state list | Select-String "module\.s3_static_website"    | Measure-Object | Select-Object -ExpandProperty Count

# Outputs з конкретного модуля
terraform output -json | ConvertFrom-Json | Where-Object { $_.s3_website_url }
terraform output s3_website_url
terraform output instance_public_ip_primary

# Граф залежностей (DOT-формат, можна скопіювати на https://dreampuf.github.io/GraphvizOnline/)
terraform graph > graph.dot

# Показати ВСЕ, що в state (великий JSON)
terraform show -json
```

### 5.3. Запустити ТІЛЬКИ один модуль (через `-target`)

`terraform plan/apply/destroy` приймає `-target=module.<name>`. Це працює
навіть коли є залежності через спільний AWS provider.

```powershell
# Тільки EC2 (без S3)
terraform plan  -target=module.ec2
terraform apply -target=module.ec2

# Тільки S3 сайт (без EC2)
terraform plan  -target=module.s3_static_website
terraform apply -target=module.s3_static_website

# Конкретний ресурс усередині модуля
terraform plan  -target=module.ec2.aws_instance.primary
terraform apply -target=module.s3_static_website.aws_s3_bucket.this
```

> ⚠️ `-target` призначений для тимчасових операцій. Не покладайтесь на нього
> в CI/CD — Terraform виводить попередження, що plan з `-target` неповний.

### 5.4. Заголовки у файлах модулів

У верхньому рядку кожного `main.tf` є банер-коментар:

```
# modules/ec2/main.tf
# MODULE: ec2
# Address prefix in state/plan:  module.ec2
# Provisions:  2 EC2 instances + shared Security Group

# modules/s3-static-website/main.tf
# MODULE: s3-static-website
# Address prefix in state/plan:  module.s3_static_website
# Provisions:  S3 bucket + website hosting + public policy + file uploads
```

### 5.5. Теги допомагають фільтрувати в AWS Console

Кожен створений ресурс отримує теги з `var.common_tags` плюс `Name`. У AWS
Console для пошуку фільтруйте за `Project = CMD521` або `ManagedBy = Terraform`.

---

## 6. Структура проєкту

```
.
├── modules/
│   ├── ec2/                       # модуль EC2
│   │   ├── main.tf                #   2× aws_instance + SG + rules
│   │   ├── variables.tf           #   aws_image_id, instance_type, ...
│   │   ├── outputs.tf             #   instance_public_ip_*
│   │   └── README.md
│   └── s3-static-website/         # модуль статичного сайту
│       ├── main.tf                #   bucket + ownership + ACL + public-access
│       ├── website.tf             #   website config + policy + encryption + versioning
│       ├── upload.tf              #   fileset() + setsubtract() + content_type map
│       ├── error.tf               #   synthetic error.html (inline)
│       ├── variables.tf           #   bucket_name, indexing, source_dir, tags
│       ├── outputs.tf             #   bucket_id, website_url, object_count
│       └── README.md
│
├── files/
│   └── Web/                       # джерело файлів для upload (НЕ редагується Terraform)
│       ├── index.html
│       ├── css/  js/  i/
│       └── ...
│
├── providers.tf                   # AWS provider
├── versions.tf                    # Terraform >= 1.3, AWS ~> 6.0
├── main.tf                        # module "ec2" {} + module "s3_static_website" {}
├── variables.tf                   # всі input vars (credentials + EC2 + S3)
├── outputs.tf                     # агреговані outputs обох модулів
│
├── terraform.tfvars               # ← реальні ключі (gitignored)
├── terraform.tfvars.example       # ← шаблон
│
└── README.md                      # ← цей файл
```

---

## 7. Змінні (root)

Повний список у `variables.tf`. Усі чутливі поля (`aws_access_key`,
`aws_secret_key`) помічені `sensitive = true`.

| Ім'я | Тип | За замовч. | Опис |
|------|-----|-----------|------|
| `aws_access_key`            | string (sensitive) | — | AWS access key |
| `aws_secret_key`            | string (sensitive) | — | AWS secret key |
| `aws_region`                | string | `eu-north-1` | Регіон |
| `aws_zone`                  | string | `eu-north-1a` | AZ (для резерву) |
| `aws_image_id`              | string | `ami-0aba…` | AMI для Ubuntu |
| `aws_image_id_2`            | string | `ami-07b8…` | AMI для Amazon Linux |
| `aws_instance_type`         | string | `t3.small` | Тип EC2 |
| `aws_key_name`              | string | `Stockholm_3` | Key pair |
| `s3_bucket_name`            | string | `terraform-static-website-eu-north-1` | **Має бути глобально унікальним** |
| `s3_force_destroy`          | bool   | `true` | Дозволити `destroy` бакета з об'єктами |
| `s3_versioning_enabled`     | bool   | `true` | Версіонування |
| `s3_website_index_document` | string | `index.html` | Index doc |
| `s3_website_error_document` | string | `error.html` | Error doc |
| `common_tags`               | map    | `{ManagedBy,Project}` | Дефолтні теги |

> Якщо `terraform-static-website-eu-north-1` зайнятий — задайте інше
> ім'я через `terraform.tfvars` або передайте опцією при `apply`:
> `terraform apply -var "s3_bucket_name=my-cool-bucket-name"`.

---

## 8. Outputs (root)

| Ім'я | Опис |
|------|------|
| `instance_public_ip_primary`   | Публічна IP Ubuntu EC2 |
| `instance_public_ip_secondary` | Публічна IP Amazon Linux EC2 |
| `security_group_id`            | ID спільного SG |
| `s3_bucket_id`                 | Назва бакета |
| `s3_bucket_arn`                | ARN бакета |
| `s3_bucket_domain_name`        | S3 REST endpoint (не website) |
| `s3_website_endpoint`          | S3 website endpoint (лише HTTP) |
| **`s3_website_url`**           | **Готовий URL `http://<endpoint>` — відкрийте в браузері** |
| `s3_uploaded_object_count`     | Скільки файлів завантажено |

Переглянути всі:

```powershell
terraform output
```

Конкретно URL сайту:

```powershell
terraform output -raw s3_website_url
```

---

## 9. Що потрапляє в S3, а що — ні

Модуль `s3-static-website/upload.tf` використовує `fileset()` для переліку файлів
і `setsubtract()` для виключень.

**Завантажується:**

- всі `**/*.html`
- вміст `css/`, `js/`, `i/` (повністю)

**Виключається:**

- `**/*.php` (немає PHP на статичному S3)
- `**/.DS_Store`
- `**/Readme.txt`, `**/License.txt` (метадані Bootstrap)
- `scss/**` (вихідні SCSS, а не готовий CSS)

**Синтетично створюється:**

- `error.html` — 404 сторінка (див. `modules/s3-static-website/error.tf`)

**Content-Type** визначається за розширенням через мапу `mime_types` у
`upload.tf`. Якщо розширення немає — `application/octet-stream`.

---

## 10. Типові сценарії

### 9.1. Перевизначити bucket name

```powershell
terraform apply -var "s3_bucket_name=my-website-prod"
```

### 9.2. Використати Cloudflare/AWS CDN замість прямого S3 endpoint

Сайт на S3 віддає тільки HTTP. Для HTTPS додайте окремий модуль
`modules/cloudfront/` пізніше — не змінюйте існуючий.

### 9.3. Оновити вміст сайту

Покладіть нові файли у `files/Web/`, потім:

```powershell
terraform plan       # побачить змінені etag'и
terraform apply      # перезавантажить тільки змінені aws_s3_object
```

### 9.4. Додати ще один EC2 (третій)

Відредагуйте `modules/ec2/main.tf` — додайте ще один `aws_instance`.
Або винесіть EC2 у for_each по `var.instances` (потребує невеликого рефактору).

### 9.5. Звільнити все

```powershell
terraform destroy
# S3 видалиться завдяки force_destroy = true
```

---

## 11. Безпека

- **Credentials** — тільки в `terraform.tfvars`, помічені `sensitive`.
  Ніколи не комітьте.
- **S3 bucket policy** — дає `s3:GetObject` будь-кому. Не кладіть туди
  приватні дані.
- **EC2 Security Group** — відкриває 22/80/ICMP на `0.0.0.0/0`.
  Прийнятно для навчального/demo, **не для продакшну**. Для production
  обмежте SSH конкретними CIDR або замініть на SSM Session Manager.
- **State** — локальний, без шифрування. Для спільної роботи перенесіть
  у S3 backend з DynamoDB lock — див. terraform-best-practices.

Деталі: `.opencode/skills/cloud-devops-architect/references/security-guidelines.md`.

---

## 12. Troubleshooting

| Проблема | Рішення |
|----------|---------|
| `Error: Bucket name already exists` | Поміняйте `s3_bucket_name` — імена S3 глобально унікальні |
| `Error: Forbidden: AccessDenied` при upload | Перевірте, що credentials мають право `s3:PutObject` |
| `Error: InvalidKeyPair.NotFound` | Створіть key pair або задайте правильний `aws_key_name` |
| `Error: No valid credential sources` | Заповніть `terraform.tfvars` |
| Plan показує деталі замість графічного виводу | Додайте `-no-color` для логів; використайте `terraform show` для плану |
| Сайт повертає 403 | Перевірте `aws_s3_bucket_policy.this` — має бути прив'язаний |
| Хочу побачити, що зміниться ПЕРЕД apply | Завжди починайте з `terraform plan` |

---

## 13. Корисні команди

```powershell
terraform fmt -recursive      # формат
terraform init                # init
terraform validate            # валідація
terraform plan                # preview
terraform apply               # apply
terraform apply -auto-approve # без підтвердження
terraform destroy             # все знести
terraform output -json        # outputs у JSON
terraform state list          # список ресурсів у state
terraform state show <addr>   # деталі конкретного ресурсу
terraform console             # REPL з `var.*` / `aws_s3_bucket.this.id` тощо
```

---

## Ліцензія

MIT
