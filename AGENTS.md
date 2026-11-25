# Hướng dẫn làm việc trong AI Travel Planner

## Stack

- Backend: .NET 10, ASP.NET Core Web API, solution `AI_Travel_Planner.sln`.
- Clean Architecture: `src/Domain`, `src/Application`, `src/Infrastructure`, `src/WebApi`.
- Frontend: React + TypeScript + Vite trong `src/WebFrontend`; linter hiện tại là Oxlint.
- Mục tiêu: giúp người dùng tự học và hoàn thành dự án, trước mắt là PA2. Giải thích bằng tiếng Việt, chia việc thành bước nhỏ có thể kiểm chứng.
- Khi làm PA2, đọc `knowledge/ai-travel-planner-brief.vi.md`, `knowledge/pa2-rubric.vi.md` và `knowledge/HUONG_DAN_HOC_VA_LAM_PA2.vi.md`. Nếu các file không có trong bản clone, nói rõ và yêu cầu nội dung cần thiết; không tự đoán rubric.

## Commands

Chạy từ thư mục gốc. Các lệnh dưới đây dựa trên cấu hình hiện có; không mặc định chúng đã được chạy thành công.

| Mục đích | Lệnh |
| --- | --- |
| Restore backend | `dotnet restore AI_Travel_Planner.sln` |
| Build backend | `dotnet build AI_Travel_Planner.sln` |
| Chạy API | `dotnet run --project src/WebApi/AITravelPlanner.WebApi.csproj` |
| Cài dependency frontend theo lockfile | `npm --prefix src/WebFrontend ci` |
| Lint frontend | `npm --prefix src/WebFrontend run lint` |
| Type check frontend | `npm --prefix src/WebFrontend run typecheck` |
| Build frontend | `npm --prefix src/WebFrontend run build` |
| Kiểm tra format | `bash scripts/check-format.sh` |
| Kiểm tra lint | `bash scripts/check-lint.sh` |
| Kiểm tra kiểu | `bash scripts/check-types.sh` |
| Chạy test | `bash scripts/check-tests.sh` |
| Chạy frontend development | `npm --prefix src/WebFrontend run dev` |

- Dùng Git Bash và bốn script `.sh`, không dùng các lệnh `.ps1` dự kiến trước đây. Prettier đã được thêm; xUnit trong `tests/AITravelPlanner.ArchitectureTests` kiểm tra khai báo phụ thuộc giữa các tầng. Chưa có contract test HTTP. Kiểm tra trạng thái kiểm chứng trong AI-LOG trước khi báo gate đã xanh.
- Chưa coi `dotnet test` là bằng chứng test thành công nếu không có test được phát hiện và thực sự chạy.
- **Bài học từ lỗi thực tế trong phiên học:** người dùng chạy các lệnh mẫu `scripts/check-*.ps1` khi file chưa được tạo. Trước khi hướng dẫn chạy script, kiểm tra file và phân biệt rõ lệnh hiện có với lệnh dự kiến.
- **Bài học từ lỗi thực tế trong phiên học:** Git Bash báo `pwsh: command not found`; máy chỉ tìm thấy `powershell.exe`. Kiểm tra shell và phiên bản trước khi dùng lệnh PowerShell. Không mặc định Windows PowerShell tương thích mọi script dành cho PowerShell 7.
- Khi tạo quality gate, dùng cùng lệnh ở local và CI; bảo toàn exit code của từng lệnh con và thử chứng minh check có thể fail.

## Conventions

- Domain giữ mô hình và quy tắc nghiệp vụ, không phụ thuộc Application, Infrastructure hoặc WebApi.
- Application phụ thuộc Domain, định nghĩa use case và abstraction. Infrastructure triển khai abstraction; WebApi xử lý HTTP và ghép DI.
- React gọi backend qua HTTP; không truy cập database hoặc nhà cung cấp model bằng key bí mật từ trình duyệt.
- Với endpoint PA2, viết và đối chiếu `docs/contract/<endpoint>.md`: quyền gọi, request/response, lỗi Problem Details RFC 9457, phân trang hoặc idempotency nếu áp dụng.
- Contract test phải kiểm tra hành vi HTTP và dữ liệu, không chỉ status code. Fixture cần cố định, tách khỏi dữ liệu địa điểm đã kiểm chứng.
- Giữ phạm vi thay đổi theo yêu cầu hiện tại. Giải thích mục đích, phần thay đổi, cách kiểm chứng và giới hạn; không triển khai toàn bộ PA2 khi người dùng chỉ yêu cầu một bước.
- Báo cáo riêng trạng thái đã đề xuất, đã triển khai, đã chạy local và đã xác minh trên CI/GitHub. Ghi sự kiện thật vào `AI-LOG.md` khi file này được tạo.
- `knowledge/` hiện được Git ignore; đặt rules, contract, test, workflow và tài liệu vận hành cần version control ở ngoài thư mục này.

### Quyền làm việc

- **Allowed:** đọc repository; sửa code và tài liệu trong phạm vi người dùng yêu cầu; chạy build, lint và test cục bộ; tạo fixture không chứa dữ liệu nhạy cảm.
- **Ask first:** thêm dependency mới, thay stack, đổi contract đã chốt, thao tác database có thể mất dữ liệu, thay cấu hình bảo vệ nhánh, triển khai công khai hoặc tạo chi phí. Nếu người dùng đã cho phép trong phiên thì tiếp tục trong phạm vi đó, không hỏi lại.
- **Never:** làm lộ secret, bịa bằng chứng, vô hiệu quality gate để merge lỗi hoặc sửa ngoài phạm vi mà không có lý do liên quan đến nhiệm vụ.

## Never

- Không đưa key model vào Git, log, frontend, bundle trình duyệt hoặc biến `VITE_*`; không in secret ra output để kiểm tra.
- Không gọi model thật trong unit test hoặc contract test; dùng fake/stub kiểm soát được.
- Không sửa test, dữ liệu eval hoặc quy tắc validator chỉ để check xanh. Nếu yêu cầu nghiệp vụ thật sự đổi, cập nhật contract, code và test với lý do rõ ràng.
- Không giao model tính tiền hoặc quyết định plan hợp lệ. `compute_cost` và `validate_plan` là code; output model qua schema và backend chạy validator lần cuối.
- Không bỏ hai bước xác nhận của sản phẩm: xác nhận ứng viên và Save; không chia sẻ plan với nhóm trước Save.
- Không vượt giới hạn agent của brief: 2 vòng sửa, 12 lần gọi tool, 90 giây. Không gửi tên/email cho model; model chỉ truy cập dữ liệu qua các tool backend được quy định.
- Không dùng dữ liệu địa điểm giả làm dữ liệu đã kiểm chứng hoặc nhận ứng viên thiếu giờ mở cửa/menu.
- Không khẳng định CI đã chặn merge, secret đã sạch trong lịch sử hoặc test đã qua khi chưa có kiểm chứng tương ứng. Không bịa incident, commit, PR hay kết quả lệnh.
- Không coi workflow CI là branch protection; không push thẳng `main` sau khi quy trình PR bắt buộc đã được bật, không bypass check đỏ.
