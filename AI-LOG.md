# Nhật ký sử dụng assistant

## Phiên học — Thêm Prettier và xUnit theo yêu cầu người dùng

- Người dùng đã cho phép rõ ràng thêm Prettier và xUnit.
- Prettier: pin 3.9.5 trong package.json/lockfile. Npm registry không truy cập được trong môi trường công cụ; dùng tarball đã có trong cache người dùng, sao chép sang cache workspace và cài offline. Dependency cuối cùng vẫn dùng phiên bản số và URL registry trong lockfile, không trỏ tới file cục bộ.
- xUnit: project `tests/AITravelPlanner.ArchitectureTests`, target net10.0, xUnit 2.9.3, runner Visual Studio 3.1.4 và Microsoft.NET.Test.Sdk 17.14.1. Thêm vào solution. Không thêm coverlet vì bước này chưa cần coverage.
- Sáu case bảo vệ khai báo phụ thuộc giữa các tầng và ngăn Domain/Application khai báo framework web. Test đọc csproj trong checkout; không phân tích mọi phụ thuộc bắc cầu và không thay contract test HTTP.
- Kiểm chứng: `format:check`, Oxlint, TypeScript và build C# warnings-as-errors thành công; C# format cho cả src/tests thành công. `dotnet test` chạy sáu case, cả sáu pass; helper TRX xác nhận sáu case đã thực thi/pass.
- Thí nghiệm cố ý: thêm FrameworkReference Microsoft.AspNetCore.App vào Domain làm một case fail (exit 1); giữ nguyên test, khôi phục project thì 6/6 pass. Tạo file TypeScript sai format làm Prettier fail exit 1; xóa đúng fixture thì format pass.
- Lần restore xUnit đầu không thành công; restore lại bằng nguồn cache NuGet cục bộ thành công. Lần chạy dotnet test cuối với restore mặc định cũng thành công vì dependency đã sẵn sàng.
- Đã cập nhật README, AGENTS và phần 7 trong tài liệu học; thêm bài thực hành test kiến trúc cụ thể, không cần tự đổi assertion để tạo lỗi.
- Chưa xác minh lại toàn bộ shell script trong Git Bash do giới hạn Win32 error 5 đã ghi ở mục trước; các lệnh con được kiểm chứng qua PowerShell. Chưa có workflow CI, branch protection, frontend behavioral test hay contract test endpoint. Chưa làm thử clone sạch.

## Phiên học — Hoàn thiện script Git Bash và phần 7

- Công cụ: Codex; giữ Oxlint hiện có, không thay linter.
- Changed: điền nội dung bốn `scripts/check-*.sh`; thêm kiểm tra báo cáo TRX bằng Node chuẩn, `.editorconfig`, `.gitattributes`, cấu hình analyzers và các npm scripts format/typecheck. Cập nhật phần 7 và hướng dẫn CI sang Bash.
- Thực hiện format lại các file C# template theo cấu hình mới; không đổi hành vi nghiệp vụ.
- Các thí nghiệm cố ý, đã chạy lệnh con qua PowerShell:
  - Frontend `debugger` làm Oxlint fail exit 1 với `no-debugger`.
  - Gán string vào number làm TypeScript fail exit 1, TS2322.
  - `throw exception` làm build warnings-as-errors fail exit 1, CA2200.
  - Fixture C# sai khoảng trắng làm format fail exit 2.
  - Đã xóa đúng các fixture tạm sau thử nghiệm; format C# baseline chạy lại thành công.
  - Helper TRX được thử với báo cáo tổng hợp: thiếu report, 0 test, chưa pass hết đều exit 1; 2/2 test pass thì exit 0. Đây là thí nghiệm helper, không phải test nghiệp vụ của sản phẩm.
- Giới hạn môi trường: Git Bash từ công cụ bị Win32 error 5 (CreateFileMapping). `dotnet format` ở chế độ solution bị lỗi truy cập named pipe; chuyển kiểm tra whitespace theo folder để không cần MSBuild workspace. Không tuyên bố đã chạy trọn vẹn bốn script Bash.
- Chưa thực hiện: cài Prettier/xUnit, tạo bộ test .NET hoặc contract test. Đã hỏi người dùng vì AGENTS.md yêu cầu hỏi trước khi thêm dependency. Script format frontend và test chưa được đánh dấu xanh.
- Rejected: không trả success khi thiếu test project, không dùng báo cáo test cũ, không thêm test luôn đúng để làm gate xanh.
- Không tạo workflow, bật protection hoặc tuyên bố có bằng chứng PR đỏ/xanh ở bước này.

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
