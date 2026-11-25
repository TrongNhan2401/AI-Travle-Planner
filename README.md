# AI Travel Planner

Dự án tự học: backend .NET 10 theo Clean Architecture và frontend React + TypeScript + Vite.

## Cấu hình và secret

- Xem [bài học cấu hình và secret](docs/learning/CONFIGURATION_AND_SECRETS.vi.md).
- [.env.example](.env.example) liệt kê biến môi trường đang hỗ trợ, không chứa giá trị. Đây là bản kê cấu hình; backend không tự nạp `.env`.
- Backend đã có `UserSecretsId` để hỗ trợ User Secrets ở môi trường Development. Chưa tạo hoặc lưu API key thật.
- Hiện chưa tích hợp nhà cung cấp model, chưa có model được chọn và chưa cấu hình spending cap. Thay đổi ở mục 6.3 không gọi model hoặc tạo chi phí API. Trước khi tích hợp model cần ghi lại model, giới hạn chi phí thực tế và cách đo chi phí mỗi plan.
- Không đặt key trong frontend hoặc biến `VITE_*`. Khi chưa tích hợp model, việc build và kiểm tra không cần model key.

## Các lệnh hiện có

Chạy từ thư mục gốc, sau khi cài .NET SDK 10 và Node.js tương thích với phiên bản Vite trong project:

```bash
dotnet restore AI_Travel_Planner.sln
dotnet build AI_Travel_Planner.sln
npm --prefix src/WebFrontend ci
npm --prefix src/WebFrontend run lint
npm --prefix src/WebFrontend run build
```

Chạy ứng dụng trong hai terminal:

```bash
dotnet run --project src/WebApi/AITravelPlanner.WebApi.csproj
```

```bash
npm --prefix src/WebFrontend run dev
```

## Quality checks trong Git Bash

Bốn script `.sh` đã có nội dung. Không cần `pwsh`; chạy từng lệnh từ thư mục gốc:

```bash
bash scripts/check-format.sh
bash scripts/check-lint.sh
bash scripts/check-types.sh
bash scripts/check-tests.sh
```

- Format: C# whitespace theo folder và frontend Prettier 3.9.5, đã pin trong devDependencies/lockfile.
- Lint: C# analyzers + warnings-as-errors và Oxlint + deny-warnings.
- Types: build C# và TypeScript, không bundle frontend.
- Tests: chạy xUnit trong `tests/AITravelPlanner.ArchitectureTests`, xuất TRX vào `.artifacts/test-results/`, fail nếu không có project/test được thực thi hoặc có test không pass. Chưa có frontend test runner hoặc contract test endpoint.

Trước khi chạy cần restore backend và `npm ci` như trên. Prettier và xUnit đã được thêm. Sáu test kiến trúc kiểm tra các khai báo ProjectReference được phép và việc Domain/Application không khai báo FrameworkReference. Chúng đọc file project thật, không gọi model, không thay thế contract test hoặc phân tích mọi phụ thuộc bắc cầu. Trạng thái kiểm chứng và giới hạn môi trường được ghi trong `AI-LOG.md`.

Để sửa format C# dùng `dotnet format whitespace src --folder`; với test dùng `dotnet format whitespace tests --folder`. Với frontend dùng `npm --prefix src/WebFrontend run format:write`. Các check chỉ kiểm tra, không tự sửa. Frontend và API hiện vẫn là template.

### Hiểu bộ test đầu tiên

Mở `tests/AITravelPlanner.ArchitectureTests/DependencyRulesTests.cs`:

- Bốn case kiểm tra project chỉ tham chiếu những tầng được phép.
- Hai case kiểm tra Domain và Application không khai báo phụ thuộc framework web.
- `[Theory]` chạy cùng một test với từng bộ dữ liệu `[InlineData]`; vì vậy hai phương thức tạo thành sáu case.
- Các test tìm thư mục gốc từ vị trí assembly đang chạy, rồi đọc `.csproj`. Chạy chúng trong checkout có mã nguồn.

Để học, chạy `bash scripts/check-tests.sh` và đọc kết quả 6/6. Hướng dẫn tạo vi phạm thật, thấy test đỏ rồi sửa lại nằm trong phần 7.4 của tài liệu PA2 tại `knowledge/` (thư mục này được Git ignore).
