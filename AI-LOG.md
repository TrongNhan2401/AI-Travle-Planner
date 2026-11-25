# Nhật ký sử dụng assistant

## Phiên học — Các lệnh check chưa sẵn sàng

- Công cụ: Codex trong workspace; phiên bản model không được xác minh trong nhật ký này.
- Sự kiện thật: người dùng chạy bốn lệnh `pwsh -NoProfile -File scripts/check-*.ps1` từ Git Bash và nhận `pwsh: command not found`.
- Kiểm tra: máy tìm thấy `powershell.exe`, không tìm thấy `pwsh`; các script được nói tới cũng chưa tồn tại.
- Changed: `AGENTS.md` yêu cầu kiểm tra file script và shell trước khi hướng dẫn chạy; phân biệt lệnh dự kiến với lệnh hiện có.
- Rejected: không coi các lệnh mẫu trong lộ trình học là quality gate đã triển khai; không mặc định đổi sang `powershell.exe` sẽ tương thích mọi script PowerShell 7.
- Bằng chứng: hai dòng bài học trong mục Commands của `AGENTS.md`; lỗi gốc nằm trong hội thoại học, chưa có commit/PR bằng chứng riêng.

## Phiên học — Mục 6.3, cấu hình và secret

- Công cụ: Codex để đọc repository, sửa file và chạy kiểm tra; tài liệu Microsoft, Vite và Gitleaks để đối chiếu hành vi cấu hình.
- Hiện trạng: backend là template ASP.NET Core .NET 10, chưa tích hợp model hoặc database; `WebApplication.CreateBuilder(args)` dùng cấu hình mặc định.
- Accepted: dùng environment variables và chuẩn bị .NET User Secrets cho backend; giữ API key ngoài frontend.
- Changed: mở rộng `.gitignore` từ `.env` sang cả `.env.*`, giữ ngoại lệ `.env.example`; thêm `UserSecretsId` trong WebApi, tạo README và bài thực hành tiếng Việt.
- Rejected: không thêm biến API key/database chưa được code dùng; không thêm dependency dotenv; không tạo key thật chỉ để học PA2.
- Kiểm chứng đã chạy:
  - `git check-ignore --no-index` nhận diện `.env`, `.env.local`, `.env.production` và các file env lồng trong hai project.
  - `.env.example` không bị ignore, lệnh kiểm tra trả exit code 1 như mong đợi.
  - Lần build đầu bị hủy ở task compiler (MSB5021); không ghi nhận lần đó là thành công.
  - Chạy lại `dotnet build AI_Travel_Planner.sln --no-restore --disable-build-servers -m:1 -p:UseSharedCompilation=false`: thành công, 0 warning, 0 error.
- Chưa kiểm chứng: chạy ứng dụng để quan sát environment; đọc/ghi User Secrets thật; quét toàn bộ cây làm việc/lịch sử bằng scanner chuyên dụng. Máy chưa tìm thấy Gitleaks/TruffleHog. Không tuyên bố lịch sử Git đã sạch secret.
- Chi phí: thay đổi này không gọi model; chưa có model được chọn hoặc spending cap được cấu hình.
- Bằng chứng: `.gitignore`, `.env.example`, `src/WebApi/AITravelPlanner.WebApi.csproj`, `README.md`, `docs/learning/CONFIGURATION_AND_SECRETS.vi.md`. Chưa tạo commit hoặc PR cho bước này.
