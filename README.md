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

Bốn script `scripts/check-*.ps1` trong lộ trình học chưa được tạo. Các lệnh trên chưa thay thế một bộ quality gate PA2 hoàn chỉnh; frontend và API hiện vẫn là template.
