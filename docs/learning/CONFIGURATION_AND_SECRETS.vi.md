# Bài thực hành 6.3 — Hiểu cấu hình và giữ secret

## 1. Phân biệt cấu hình và secret

**Cấu hình** là dữ liệu giúp cùng một code chạy trong những môi trường khác nhau: tên môi trường, địa chỉ backend, mức log. **Secret** là cấu hình cần giữ kín: API key, mật khẩu database, token có quyền truy cập.

Không phải biến môi trường nào cũng bí mật. `ASPNETCORE_ENVIRONMENT=Development` là cấu hình công khai. API key có thể cho phép người khác sử dụng tài khoản dịch vụ và tạo chi phí nên phải giữ ở backend.

Trong repository hiện tại, `WebApplication.CreateBuilder(args)` thiết lập cơ chế đọc cấu hình mặc định của ASP.NET Core. Backend chưa đọc key model hoặc connection string. Vì vậy, `.env.example` chưa liệt kê `AI__ApiKey` hay mật khẩu database.

## 2. Những thay đổi đã được thực hiện

| File | Mục đích |
| --- | --- |
| `.gitignore` | Ignore `.env`, `.env.*`; cho phép `.env.example` được theo dõi |
| `.env.example` | Liệt kê tên biến hiện dùng, giá trị để trống |
| `src/WebApi/AITravelPlanner.WebApi.csproj` | Thêm `UserSecretsId` cho môi trường phát triển |
| `README.md` | Ghi cách cấu hình và trạng thái chưa dùng model/spending cap |

`UserSecretsId` chỉ là mã định danh kho cấu hình cục bộ, không phải mật khẩu. Commit mã này được; mỗi người dùng có kho riêng bên ngoài repository. Chưa có secret thật nào được tạo bởi bước này.

## 3. Nên đặt dữ liệu ở đâu?

| Nơi đặt | Dùng cho gì? | Có đưa lên Git không? |
| --- | --- | --- |
| `appsettings.json` | Cấu hình chung không bí mật | Có |
| `launchSettings.json` | Cấu hình chạy local không bí mật | Có |
| `.env.example` | Danh sách tên biến và ghi chú, không có giá trị | Có |
| `.env`, `.env.local`, `.env.production` | Cấu hình cục bộ nếu công cụ có hỗ trợ đọc | Không theo quy ước dự án |
| .NET User Secrets | Secret backend khi phát triển | Không; nằm ngoài repo |
| Biến môi trường của tiến trình backend | Cấu hình do shell/nền tảng triển khai truyền vào | Không commit giá trị bí mật |

`.gitignore` chỉ giúp Git bỏ qua file chưa được theo dõi. Nó không mã hóa file, không ngăn code frontend đọc dữ liệu, không xóa file đã track và không xóa lịch sử commit cũ.

## 4. Thực hành ngay trên Git Bash, không cần pwsh

### Bước A — Kiểm tra quy tắc ignore mà không cần tạo file bí mật

Chạy từ thư mục gốc:

```bash
git check-ignore --no-index .env .env.local .env.production src/WebApi/.env.local src/WebFrontend/.env.production
```

Kết quả phải liệt kê các đường dẫn trên. `git check-ignore` kiểm tra quy tắc cho cả đường dẫn chưa tồn tại.

Kiểm tra riêng file mẫu:

```bash
git check-ignore --no-index .env.example
```

Lệnh này phải không in gì và trả exit code 1: nghĩa là file mẫu không bị ignore. Với lệnh này, exit code 1 là kết quả mong đợi, không phải mọi lệnh trả 1 đều là lỗi cần sửa.

### Bước B — Truyền một cấu hình không bí mật vào backend

Trong Git Bash, chạy:

```bash
ASPNETCORE_ENVIRONMENT=Development dotnet run --project src/WebApi/AITravelPlanner.WebApi.csproj --no-launch-profile --urls http://localhost:5069
```

Đọc dòng `Hosting environment: Development` khi ứng dụng khởi động. Biến ở đầu lệnh chỉ truyền vào tiến trình đó, không lưu thành file và không có giá trị secret. Dừng bằng Ctrl+C.

`--no-launch-profile` giúp bài học không bị cấu hình môi trường trong `launchSettings.json` che khuất. Bạn cũng có thể đổi thành `Production` và khởi động lại để quan sát khác biệt; không cần chỉnh code hay commit giá trị này.

**Bài học:** một biến môi trường được tiến trình nhận và một dòng trong file `.env` là hai việc khác nhau. Với backend hiện tại, copy `.env.example` thành `.env` chưa làm ASP.NET Core nạp file đó. Không cần thêm thư viện dotenv ở bước này.

### Bước C — Hiểu User Secrets trước khi có API key

Dự án WebApi đã có `UserSecretsId`. Với cấu hình mặc định, ASP.NET Core đọc User Secrets khi môi trường là Development. Hiện chưa cần lưu gì vì backend chưa dùng secret.

Khi tích hợp model sau này, backend có thể đọc cấu hình bằng:

```csharp
var apiKey = builder.Configuration["AI:ApiKey"];
```

Đây là ví dụ cho bước tương lai, chưa phải code đã thêm vào ứng dụng. Khi dùng environment variable, tên tương ứng là `AI__ApiKey`: hai dấu gạch dưới được ánh xạ thành dấu hai chấm.

Để hiểu cú pháp User Secrets, lệnh sau **chỉ minh họa bằng giá trị giả**, chưa cần chạy ở bước hiện tại:

```bash
dotnet user-secrets set "AI:ApiKey" "DEMO_NOT_A_REAL_KEY" --project src/WebApi/AITravelPlanner.WebApi.csproj
dotnet user-secrets remove "AI:ApiKey" --project src/WebApi/AITravelPlanner.WebApi.csproj
```

Lệnh đầu ghi vào hồ sơ người dùng ngoài repository, lệnh sau xóa giá trị ví dụ. Đừng dùng lệnh set lên key đang tồn tại để thử, vì nó sẽ ghi đè giá trị cũ. Không đưa key thật vào câu lệnh minh họa trong tài liệu, chat hoặc lịch sử shell. Khi có key thật, chọn cách nhập an toàn theo môi trường của bạn, ví dụ công cụ quản lý User Secrets cục bộ của IDE, và không chụp/chia sẻ giá trị đó.

User Secrets giúp tách dữ liệu khỏi mã nguồn nhưng **không mã hóa dữ liệu**, không phải kho secret production. Không chạy `dotnet user-secrets list` để lấy output dán vào chat: lệnh ấy có thể in giá trị thật.

Xem [hướng dẫn User Secrets của Microsoft](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets?view=aspnetcore-10.0) về cách lưu, ánh xạ biến môi trường và giới hạn bảo vệ.

## 5. Vì sao VITE_* không giữ được API key?

```text
Trình duyệt React → API của bạn → Nhà cung cấp model
                                  ↑
                     Backend mới được dùng API key
```

Vite cho phép mã frontend truy cập biến mang tiền tố `VITE_`; khi được dùng trong mã client, giá trị có thể xuất hiện trong bundle tải xuống trình duyệt. Người dùng có thể đọc code và request bằng công cụ trình duyệt. File `.env` được Git ignore không thay đổi điều này.

Ví dụ URL API công khai có thể dùng `VITE_API_BASE_URL` khi ứng dụng cần nó; API key model không được dùng theo cách ấy. Không thêm biến URL chỉ để có đủ file cấu hình khi frontend chưa đọc nó.

Nguồn: [Vite — Env Variables and Modes](https://vite.dev/guide/env-and-mode.html).

## 6. Kiểm tra secret ở hiện tại và trong lịch sử

Kiểm tra hai phạm vi riêng:

1. Cây làm việc: gồm cả file đã track và file mới có thể sắp commit.
2. Lịch sử: các commit và nhánh/ref có sẵn ở local. Secret bị xóa khỏi file hiện tại có thể vẫn còn trong commit cũ.

Không dùng lệnh tìm kiếm rồi dán toàn bộ dòng khớp vào chat. Công cụ quét nên che giá trị (`redact`) và không lưu báo cáo có secret vào repository.

Máy hiện chưa tìm thấy `gitleaks` hoặc `trufflehog`. Khi đã cài một phiên bản Gitleaks hỗ trợ các lệnh sau, có thể chạy từ thư mục gốc:

```bash
gitleaks dir . --redact
gitleaks git . --redact --log-opts="--all"
```

Đây là lệnh cần công cụ cài riêng, **không phải check đã chạy thành công**. Kiểm tra `gitleaks version` và `gitleaks --help` trước vì phiên bản cũ có giao diện khác. Tham khảo [repository chính thức Gitleaks](https://github.com/gitleaks/gitleaks).

Quét lịch sử local không chứng minh mọi ref trên remote hoặc commit không còn truy cập được đều sạch. Nếu chỉ clone nông, cần kiểm tra phạm vi lịch sử trước. Ngay cả scanner không phát hiện cũng không phải bảo đảm tuyệt đối: nó chỉ nhận diện các mẫu được hỗ trợ.

Nếu phát hiện key thật đã commit: thu hồi/rotate key trên nhà cung cấp trước, cập nhật nơi sử dụng, ghi sự cố không chứa giá trị key vào `AI-LOG.md`. Xóa key khỏi file hiện tại không làm key cũ hết hiệu lực. Việc viết lại lịch sử cần xem xét tác động đến người cùng làm; không tự ý thực hiện.

## 7. Spending cap khi chưa chọn model

Hiện chưa tích hợp nhà cung cấp model, nên trạng thái đúng là **chưa cấu hình spending cap**, không phải “đã giới hạn chi phí về 0”. Bước này không gọi API model.

Khi bắt đầu tích hợp:

1. Chọn nhà cung cấp/model và kiểm tra cách tính phí hiện hành.
2. Kiểm tra nền tảng có hard cap thật hay chỉ gửi cảnh báo ngân sách.
3. Ghi rõ giới hạn, phạm vi áp dụng và hành vi khi chạm giới hạn trong README/AI-LOG.
4. Bổ sung quota ứng dụng phù hợp, và ghi chi phí đo được mỗi plan.
5. Tiếp tục dùng fake/stub trong test; không cần key thật để CI kiểm thử contract.

Không ghi một biến ngân sách tùy ý rồi coi như đã có cơ chế chặn chi phí.

## 8. Tự giải thích trước khi chuyển sang buổi tiếp theo

1. `.env.example` chứa tên biến và `.env` chứa giá trị khác nhau ở điểm nào?
2. Vì sao `.env` được ignore vẫn có thể làm key lộ qua frontend?
3. `UserSecretsId` có phải secret không? Secret thực sự được lưu ở đâu?
4. Vì sao `.gitignore` không xử lý được một key đã commit?
5. Vì sao chưa dùng model thì không cần tạo API key chỉ để hoàn thành PA2?

Sau bài này, phần bảo vệ file cấu hình và hướng dẫn nạp cấu hình đã có nền tảng. Quét bằng scanner chuyên dụng và spending cap cho nhà cung cấp thật vẫn cần được thực hiện khi có công cụ/dịch vụ tương ứng; không đánh dấu chúng là đã hoàn thành.
