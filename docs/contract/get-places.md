# API danh mục địa điểm — Contract dự thảo, phiên bản 1

**Trạng thái:** bản người dùng chọn để review và triển khai tiếp; chưa khẳng định API đã có hành vi tương ứng. Bản tiếng Việt này thay thế contract trước trong cùng đường dẫn, dựa trên bản tiếng Anh người dùng cung cấp.

### Nguồn và xuất xứ quyết định

- **Cấu trúc IA#3:** mẫu thực tế trong workspace là `knowledge/CONTRACT_IA#3.md`, đã đọc ở phiên soạn trước. Giữ năm mục chính, danh mục lỗi trước tài nguyên và quy tắc request/xử lý/response/idempotency. Các mục bổ sung phục vụ review và kế hoạch test.
- **Yêu cầu bài tập:** brief và rubric tiếng Việt có trong knowledge, đã đọc ở phiên trước. PA2 yêu cầu quyền rõ ràng, request/response cụ thể, lỗi RFC 9457, phân trang, chính sách thay đổi và contract test. Brief yêu cầu ứng viên đã kiểm chứng, có giờ mở cửa và dữ liệu menu/vé.
- **Quyết định nhóm:** public access, bốn query và giới hạn cụ thể, ID integer, fixture, parsed-query validation, header, thông báo lỗi và chính sách tương thích là lựa chọn thiết kế từ bản người dùng cung cấp; không quy chúng thành giới hạn giảng viên ấn định.
- Các tài liệu knowledge bị Git ignore và có thể thiếu trong clone mới. Contract này tự chứa quy tắc cần để viết client/test. Không giữ các khẳng định “tài liệu không có trong checkout” từ bản tiếng Anh vì không đúng với workspace hiện tại.
- Chưa thực nghiệm framework parsing trong tác vụ dịch này. Mục 4 giữ ranh giới cần khảo sát. Không thêm API implementation hoặc executable test ở bước viết tài liệu.

Khi được chốt, tài liệu là nguồn sự thật. Code khác contract thì sửa code. Nếu cần đổi contract, review và ghi nhận trước, rồi cập nhật test/code trong thay đổi phân biệt được. Không sửa kỳ vọng để che bug.

## 1. Conventions — Quy ước

### Mục đích, phạm vi và truy cập

`GET /places` liệt kê danh mục public các địa điểm đủ điều kiện ở TP.HCM. Chỉ dùng ứng viên có trong catalog; không bịa địa điểm, gọi model hoặc cho model đọc database trực tiếp.

Cho phép anonymous. Không cần vai trò, login, bearer token, API key hoặc membership nhóm. Địa điểm là tài nguyên chung, không có ownership theo user. Thiếu credentials không được gây 401/403. Authorization tùy chọn không chọn danh mục khác hoặc cho xem bản ghi riêng; route vẫn anonymous kể cả authentication được cấu hình ở nơi khác.

Response không có thông tin cá nhân, lịch sử ghé thăm, plan riêng, draft hoặc bằng chứng kiểm chứng nội bộ. ID định danh địa điểm, không phải user. Full-text/geospatial search, ghi dữ liệu, đặt chỗ, thanh toán và gọi model ngoài phạm vi.

### Quy ước truyền dữ liệu

- Route chính xác **GET /places**, không prefix /v1. Đường dẫn không phiên bản này là mặt giao tiếp ban đầu, không phải legacy. Route/method khác ngoài contract.
- JSON UTF-8; property và enum phân biệt hoa thường. Integer là JSON number không phần thập phân, không phải string. ID là số nguyên dương signed 32-bit duy nhất trong catalog.
- Property response được liệt kê đều bắt buộc và không null. Client bỏ qua property response chưa biết. Unknown query key bị từ chối, khác request-field convention của mẫu menu.
- Application response có `Cache-Control: no-store`; không cam kết ETag, conditional request hoặc 304. Điều này không thiết lập snapshot xuyên request.
- Thành công dùng application/json, lỗi application/problem+json; có thể kèm charset=utf-8. Test so parsed media type, không so cách trình bày header.

## 2. Errors — Lỗi

### Danh mục lỗi ứng dụng

| type | HTTP/body status | title ổn định | Điều kiện |
| --- | --- | --- | --- |
| urn:travel-planner:problem:invalid-query | 400 | Invalid query | Parsed query sai key, occurrence, syntax, range hoặc supported value |
| urn:travel-planner:problem:internal-error | 500 | Internal error | Lỗi application/catalog ngăn response hợp lệ, kể cả catalog invariant sai |

Không có application problem type khác. Collection rỗng/trang vượt cuối trả 200. Không thêm auth/ownership error cho route public. Không có lỗi JSON request body vì operation không tiêu thụ body.

Chỉ áp dụng request tới application route. TLS, connection loss, proxy rate limit, giới hạn request-size của server, HTTP sai bị chặn trước routing và lỗi route/method khác ngoài error catalog này. Client vẫn xử lý transport/infrastructure response bất ngờ một cách phòng vệ.

### Schema Problem Details

[RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html) cho phép thiếu một số member trong những trường hợp nhất định. **Quy ước dự án** yêu cầu đủ năm member đầu bảng; không quy yêu cầu ấy cho RFC.

| Member | Kiểu JSON | Quy tắc |
| --- | --- | --- |
| type | string | Chính xác một absolute URN trong bảng lỗi |
| title | string | Chính xác title đi kèm type |
| status | integer | Bằng HTTP status, 400 hoặc 500 |
| detail | string | 400: giải thích chung an toàn không rỗng, câu chữ không cố định. 500: đúng `An unexpected error occurred. Please try again later.` |
| instance | string | `/places`, URI reference định danh path; không query, không coi là unique correlation ID |
| errors | object | Bắt buộc ở 400, vắng mặt ở 500; map exposed query key sang mảng string không rỗng, mỗi string không rỗng |

errors của 400 không rỗng; đây là dictionary thay cho array of pointers của mẫu. Key giữ spelling/case framework query collection expose. Framework gộp case variant thì báo key của group được expose, không đòi entry cho từng spelling gốc. Parsed key rỗng dùng key `""`. Không có reserved whole-query key hoặc application decoding-error category.

Client phân nhánh theo type/status, gắn lỗi theo errors key. Title là display default ổn định. Không so nguyên văn validation message/detail 400; detail 500 có thể assert chính xác. Dictionary order không có ý nghĩa. Response không lộ raw rejected value, exception, stack, SQL, connection string, đường dẫn local hoặc secret. Mọi 500 dùng detail chung và không errors.

**Lưu ý bản dịch:** giữ nguyên identifier, tên fixture, type/title và detail 500 tiếng Anh để không đổi wire contract đã được chọn. Diễn giải và hướng dẫn dùng tiếng Việt.

### Gộp lỗi và ưu tiên

Validate trước catalog access. Duyệt **mọi parsed key group** ASP.NET Core expose, trả tất cả invalid group trong một 400. Mỗi key có đúng một message theo ưu tiên:

1. Unknown key, kể cả key rỗng.
2. Known key lặp.
3. Empty value.
4. Numeric syntax sai nếu tham số số.
5. Numeric range sai hoặc enum không hỗ trợ.

Duplicate không validate thêm từng value. Unknown vẫn báo unknown dù lặp. Valid parameter không có trong errors. Message ví dụ: `Unknown query parameter.`, `Query parameter must occur once.`, `Value must not be empty.`, `Value must contain ASCII digits only.`, `Value must be between 1 and 50.`, `Value must be one of: cafe, food, attraction.`

## 3. Resources — Tài nguyên

### Place

| Property | Kiểu JSON | Quy tắc |
| --- | --- | --- |
| id | integer | Bắt buộc, không null, 1–2147483647; identity ổn định duy nhất, không phải array position |
| name | string | Bắt buộc, không null, 1–200 Unicode scalar values; không whitespace đầu/cuối hoặc control character; display name public không cần duy nhất |
| category | string | Bắt buộc, không null, đúng cafe, food hoặc attraction |
| district | string | Bắt buộc, không null, đúng q1 hoặc q3 trong phạm vi PA2; catalog code, không phải nhãn dịch |

Không gán ID sang địa điểm khác trong lifetime contract. Chỉ expose bốn property; flag eligibility không public. Included record sai dữ liệu public/ID trùng là invariant failure, trả safe 500 thay vì malformed 200. Loại ineligible record trước public-record validation.

### PlacesPage

| Property | Kiểu | Quy tắc |
| --- | --- | --- |
| items | array of Place | Bắt buộc, không null, có thể rỗng, tối đa pageSize; numeric ID tăng nghiêm ngặt, không trùng |
| page | integer | Bắt buộc không null, requested/default, 1–100000 kể cả khi rỗng |
| pageSize | integer | Bắt buộc không null, requested/default, 1–50 |
| totalItems | integer | Bắt buộc không null, count signed 32-bit không âm sau eligibility/filter, trước pagination |
| totalPages | integer | Bắt buộc không null, 0 khi totalItems=0; còn lại ceiling(totalItems/pageSize) |

Money, timestamp, order lines và historical prices của mẫu IA3 **không áp dụng** vì representation không có các field ấy.

### Fixture tham chiếu cho ví dụ và future test

Dữ liệu đề xuất, không phải dataset chính thức. Tên giả lập, flag mô phỏng verification/eligibility, không chứng minh venue thật đã được kiểm tra. Included record đều thỏa public-field rules.

| ID | Name | Category | District | City nội bộ | Verified | Eligible | Có giờ | Có menu/vé |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Fixture Cafe One | cafe | q1 | HCMC | true | true | true | true |
| 2 | Fixture Food Two | food | q1 | HCMC | true | true | true | true |
| 3 | Fixture Attraction Three | attraction | q1 | HCMC | true | true | true | true |
| 4 | Fixture Cafe Four | cafe | q3 | HCMC | true | true | true | true |
| 5 | Fixture Food Five | food | q3 | HCMC | true | true | true | true |
| 6 | Fixture Cafe Six | cafe | q1 | HCMC | true | true | true | true |
| 7 | Fixture Unverified Seven | cafe | q1 | HCMC | false | true | true | true |
| 8 | Fixture Ineligible Eight | food | q3 | HCMC | true | false | true | true |
| 9 | Fixture Outside City Nine | cafe | q1 | OTHER | true | true | true | true |
| 10 | Fixture Missing Hours Ten | cafe | q1 | HCMC | true | true | false | true |
| 11 | Fixture Missing Menu Eleven | food | q3 | HCMC | true | true | true | false |

Inclusion cần **đồng thời** city HCMC, verified true, public catalog record đã publish, không private/draft, hours present, menu/ticket present theo brief, eligible nội bộ không false. Thiếu hours/menu luôn loại dù eligible=true. Flag có thể biểu diễn/siết thêm điều kiện, không thay thế/ghi đè.

Tất cả dòng trên published/non-private/non-draft. Private/draft variant riêng luôn loại. Presence columns mô phỏng dữ liệu cần có, không chứng minh kiểm chứng thực tế. Metadata này ở nội bộ, không thêm response property. Không định nghĩa freshness threshold hoặc verification workflow; client không suy eligibility từ public representation.

Có sáu included record. Test nên đưa input không sort. Chưa khẳng định có/đã kiểm chứng dataset 150 địa điểm. Thêm district/category phải compatibility review mục 5; fixture assumption không tự trở thành quy tắc official catalog.

## 4. Endpoints

### 4.1. GET /places — Liệt kê địa điểm public đủ điều kiện

#### Header và body request

- Không cần application-specific header. Khuyến nghị Accept application/json nhưng có thể bỏ. Outcome quyết định representation bất kể Accept: success JSON/error Problem Details, không thêm application 406.
- Không cần Content-Type request. Không định nghĩa/tiêu thụ body; body nhận được bị operation bỏ qua, tùy HTTP server limits. Client nên không gửi body.
- Authorization, cookie, Idempotency-Key và header khác không đổi data/query behavior. Không phát replay header.

#### Query schema

Tất cả optional; default **chỉ khi key vắng mặt**.

| Key | Kiểu logic / parsed lexical form | Default | Giới hạn |
| --- | --- | --- | --- |
| page | Integer, ít nhất một ASCII digit `[0-9]+` | 1 | 1–100000 inclusive, chấp nhận leading zero, response là số |
| pageSize | Integer dạng `[0-9]+` | 10 | 1–50 inclusive, chấp nhận leading zero, không clamp |
| category | String case-sensitive | Không filter category | Đúng cafe, food, attraction |
| district | String case-sensitive | Không filter district | Đúng q1, q3 trong draft này |

#### Framework parsing và validation tường minh

Dùng parsed request query collection của ASP.NET Core cho request HTTP stack chấp nhận. Không thêm raw-query parser/strict UTF-8 decoder, không decode key/value lần hai. Framework/server quyết định malformed-encoding handling; không hứa application status/error location cụ thể cho raw input đó.

1. Duyệt parsed key và full value collection trước scalar binding. Match exposed spelling theo ordinal case-sensitive với page, pageSize, category, district. Page đứng riêng unknown; default model binding không thay validation policy.
2. Known key group hơn một value bị từ chối dù giống nhau, không first/last/join scalar. Nếu collection gộp case-insensitive thì Page=1&page=2 vẫn phải sai: expose Page là unknown, expose page với hai value là duplicate. Tương tự page=1&Page=2, bất kể spelling giữ lại.
3. Từ chối unknown, empty value (kể cả present key không value) và invalid value. Không trim/case-fold/normalize Unicode/bỏ filter sai/thay default cho value sai.
4. Theo ưu tiên mục 2. Numeric bounds không overflow: digit sequence quá bound dù dài trong HTTP limits là range error, không 500. Nhiều leading zero không đổi numeric value.

Ở parsed boundary, ` 1`, `+1`, `1 `, `-1`, `1.0`, `1e2`, non-ASCII digit là numeric syntax sai. 0 ngoài range, 01 là 1. Cafe, `cafe ` và literal `%63afe` không phải category hỗ trợ; không decode literal cuối thành cafe.

**Phải xác minh trước khi chấp nhận implementation:** .NET 10 collection expose spelling/value count thế nào cho same/mixed-case duplicate cả hai thứ tự. Middleware mất occurrence không được dùng làm boundary. Khảo sát ordinary percent-encoded key/value, raw/encoded plus, malformed encoding, bare key, empty separator trên server/test host chọn. Chưa chạy các khảo sát trong tác vụ này; raw encoding/separator là characterization task, không bịa acceptance guarantee. Không cần custom parser để giữ edge case của draft trước. Rejection trước route không cần application Problem Details.

#### Xử lý, sorting và pagination

Một coherent catalog read cho mỗi valid query response:

1. Chọn record thỏa mọi inclusion condition mục 3, gồm hours/menu; flag không bypass thiếu data. Excluded record không vào items/totals.
2. Validate included public records và unique ID; invariant sai → 500.
3. Filter category/district bằng exact equality, kết hợp AND.
4. Tính totalItems sau filter.
5. Sort **numeric ID ascending**, không lexicographic/input/name/culture; unique ID tạo total stable order.
6. offset=(page-1)*pageSize; skip offset, take tối đa pageSize. Metadata từ cùng filtered set.

Valid page vượt cuối trả 200/items=[], giữ requested page/size, totals mô tả mọi match. Empty filtered set có cả hai totals 0, bất kể page.

Mỗi response items/totals nhất quán. Không snapshot token/cursor: catalog đổi giữa request có thể shift/remove/repeat item xuyên trang/đổi total. Cùng unchanged snapshot và query tương đương sau normalization trả equal JSON values; hai consecutive page không overlap. Không hứa JSON whitespace/property order byte-identical.

#### Ví dụ thành công và lỗi

Mọi 200 bên dưới có Content-Type application/json, Cache-Control no-store; error cũng no-store. Dùng fixture không concurrent modification.

**A. GET /places**, 200 mặc định:

```json
{
  "items": [
    { "id": 1, "name": "Fixture Cafe One", "category": "cafe", "district": "q1" },
    { "id": 2, "name": "Fixture Food Two", "category": "food", "district": "q1" },
    { "id": 3, "name": "Fixture Attraction Three", "category": "attraction", "district": "q1" },
    { "id": 4, "name": "Fixture Cafe Four", "category": "cafe", "district": "q3" },
    { "id": 5, "name": "Fixture Food Five", "category": "food", "district": "q3" },
    { "id": 6, "name": "Fixture Cafe Six", "category": "cafe", "district": "q1" }
  ],
  "page": 1, "pageSize": 10, "totalItems": 6, "totalPages": 1
}
```

**B. GET /places?category=cafe&district=q1&page=2&pageSize=1**, 200:

```json
{
  "items": [
    { "id": 6, "name": "Fixture Cafe Six", "category": "cafe", "district": "q1" }
  ],
  "page": 2, "pageSize": 1, "totalItems": 2, "totalPages": 2
}
```

**C. GET /places?page=4&pageSize=2**, 200 vượt cuối:

```json
{ "items": [], "page": 4, "pageSize": 2, "totalItems": 6, "totalPages": 3 }
```

**D. GET /places?category=attraction&district=q3**, 200 không match:

```json
{ "items": [], "page": 1, "pageSize": 10, "totalItems": 0, "totalPages": 0 }
```

**E. GET /places?page=0&pageSize=&category=Cafe&sort=id**, nhiều key sai:

```http
HTTP/1.1 400 Bad Request
Content-Type: application/problem+json
Cache-Control: no-store

{
  "type": "urn:travel-planner:problem:invalid-query",
  "title": "Invalid query",
  "status": 400,
  "detail": "One or more query parameters are invalid.",
  "instance": "/places",
  "errors": {
    "page": ["Value must be between 1 and 100000."],
    "pageSize": ["Value must not be empty."],
    "category": ["Value must be one of: cafe, food, attraction."],
    "sort": ["Unknown query parameter."]
  }
}
```

**F. Catalog exception cho GET /places hợp lệ:**

```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/problem+json
Cache-Control: no-store

{
  "type": "urn:travel-planner:problem:internal-error",
  "title": "Internal error",
  "status": 500,
  "detail": "An unexpected error occurred. Please try again later.",
  "instance": "/places"
}
```

#### Retry và idempotency

GET read-only: không tạo/sửa/publish/reserve/charge/start agent run. Operational log bình thường không phải catalog mutation. Không cần Idempotency-Key, key storage, body fingerprint, transaction replay, replay status/header/retention. Những cơ chế của IA3 order **không áp dụng** vì không có creation/publication effect cần deduplicate.

Client có thể retry transport failure/500 với bounded retry và backoff. Không retry mù unchanged invalid query sau 400, phải sửa query. Retry không pin snapshot; catalog đổi có thể trả khác. Endpoint menu/order khác của IA3 **không áp dụng**, draft chỉ có collection operation này.

## 5. Versions and the legacy API — Phiên bản và API cũ

Giữ tiêu đề IA3. Legacy Places API **không áp dụng** vì chưa định nghĩa. Không bịa migration/history/deprecation/Sunset date.

Compatibility policy đề xuất:

- Compatible: thêm response property client bỏ qua, sửa diễn đạt không đổi nghĩa, thêm optional query mà vắng mặt giữ behavior cũ. Unknown key vẫn sai tới khi contract revision được review hỗ trợ.
- Breaking: xóa/đổi tên required property, đổi type/nullability/path/default/bound/parsing/sort/eligibility/error type/status/shape, public thành authenticated. Thêm response enum value là breaking vì client có thể exhaustively xử lý tập đã công bố.
- Error type mới trên request path cũ cần compatibility review/test matrix mới; không tự coi additive vì IA3 phân loại như vậy.
- Catalog add/remove/name correction trong schema/eligibility hiện hành là data change, không API-version change.
- Breaking revision dùng explicit route mới như /v2/places và contract review riêng. Giữ /places trong migration. Công bố ngày deprecation thật, migration guide, removal date với ít nhất 90 ngày báo trước; khi đó phát Deprecation, Sunset, Link successor-version trên old-route response đúng ngày/URL đã duyệt.
- Hiện không phát deprecation header. Contract/test/code change phải traceable, không rewrite history để dựng failing-check evidence.

## 6. Giả định, giới hạn và quyết định cần review

Giữ baseline bản người dùng cung cấp: page tối đa 100000, pageSize mặc định 10/tối đa 50, enum và strict unknown/duplicate/empty; không đổi ngầm các giá trị ấy. Chúng là lựa chọn thiết kế, không phải giới hạn giảng viên ấn định.

Trước khi đóng băng, review:

1. Integer ID/fixture giả. Hours và menu presence là brief requirement, không tùy chọn bỏ qua.
2. Parsed-query với spelling/value-count validation, leading zero, một lỗi mỗi invalid group theo precedence; hoàn thành characterization.
3. Fixed representation bất kể Accept, ignored body/header không liên quan, no-store để không thêm problem type ngoài phạm vi.
4. Safe nonfixed 400 detail, fixed generic 500 detail, coherent read mỗi response, không cross-request snapshot.
5. Versioning và 90-day notice đề xuất, không giả định legacy deployment/schedule thật.

Fixture PA2 nhỏ, chỉ q1/q3. Trước production data phải đối chiếu district/category/eligibility với product rules và review contract change. Không định nghĩa cách triển khai storage/cache/real verification/auth nơi khác. Filter giá/giờ và tính năng sản phẩm khác sẽ cần thiết kế tiếp, không coi đã hoàn thành toàn brief.

## 7. Ma trận acceptance / contract test tương lai

Đây là case **dự kiến, chưa viết/chạy** ở tác vụ này. Mặc định fixture được xáo input order, không login, fresh controlled catalog. Mỗi biến thể ngăn dấu chấm phẩy là input test riêng. IQ = urn:travel-planner:problem:invalid-query; IE = urn:travel-planner:problem:internal-error.

Assertion chung mọi application response: media type/no-store, valid JSON, required property/type, không secret/exception leak. Mọi 200: đầy đủ Place field rule, requested/default metadata, exact ID/totals, không null/duplicate. Mọi error: đủ Problem Details, exact type/title/status, HTTP/body status bằng nhau, instance=/places. Mọi 400: exact invalid-key set, một nonempty message mỗi exposed invalid group, không valid-key error, safe nonempty detail không so nguyên văn. Mọi 500: exact generic detail, không errors. Không so human validation sentence/JSON property order. Characterization row không hứa application status cho malformed input bị framework/server đổi/chặn.

| ID | Request / controlled condition | Status | Type | Assertion bổ sung |
| --- | --- | --- | --- | --- |
| GP01 | /places không Authorization/cookie | 200 | — | ID 1–6, page 1, size 10, totals 6/1; không challenge/redirect |
| GP02 | /places?page=1&pageSize=10 | 200 | — | JSON value bằng GP01 cùng fixture |
| GP03 | /places?category=cafe | 200 | — | ID [1,4,6], totals 3/1 |
| GP04 | /places?district=q3 | 200 | — | ID [4,5], totals 2/1 |
| GP05 | /places?category=cafe&district=q1&page=2&pageSize=1 | 200 | — | ID [6], totals 2/2, AND |
| GP06 | page=1&pageSize=2 rồi page 2 | 200 | — | [1,2] rồi [3,4], không overlap, totals 6/3 cả hai |
| GP07 | page=1&pageSize=1; page=100000&pageSize=50 | 200 | — | Đầu [1], tổng 6/6; sau [], page 100000/size50, tổng 6/1 |
| GP08 | page=4&pageSize=2 | 200 | — | [], page4, tổng 6/3 |
| GP09 | category=attraction&district=q3; thêm page=5 | 200 | — | [], tổng 0/0, page lần lượt 1/5 |
| GP10 | Empty catalog, /places | 200 | — | [], tổng 0/0, giữ defaults |
| GP11 | Fixture thêm private/draft variants | 200 | — | ID7–11/private/draft vắng, tổng vẫn6; không internal/personal field |
| GP12 | sort=id; Page=1; empty exposed key | 400 | IQ | Key lỗi sort, Page, chuỗi rỗng |
| GP13 | page=1&page=1; category=cafe&category=food; Page=1&page=2; page=1&Page=2 | 400 | IQ | Lặp/mixed-case bị chặn cả hai order; errors dùng exposed group key; parameterize mọi known key |
| GP14 | page=; pageSize=; category=; district=; parsed key không value | 400 | IQ | Present-empty không thành default; bare-key transport ở GP21 |
| GP15 | Parsed page abc/1.0/1e2/-1/non-ASCII digit; tương tự pageSize | 400 | IQ | Correct numeric key, ASCII grammar, encode theo hành vi đã xác minh |
| GP16 | page 0/100001/số100digit; pageSize 0/51/số100digit | 400 | IQ | Range error, không clamp/overflow/500 |
| GP17 | category Cafe/museum; district Q1/q2 | 400 | IQ | Exact enum, không ignore invalid filter |
| GP18 | Parsed page ` 1`/`+1`/`1 `; category `cafe ` | 400 | IQ | Không trim/permissive conversion |
| GP19 | page=01&pageSize=01 | 200 | — | ID[1], page/size1/1, tổng6/6, không custom parser |
| GP20 | Parsed category literal `%63afe` hoặc cafe;district=q1 | 400 | IQ | Không decode lần hai/tách filter trong value |
| GP21 | Characterize host: encoded key/value, raw/encoded plus, malformed encoding, bare key, empty separator | Chỉ khảo sát | Chưa ấn định | Ghi actual parsed keys/counts/values/HTTP boundary; không bịa decoding type/custom parser; accepted input theo normal rules |
| GP22 | Ví dụ E; page=&page=x&district=Q1&other=1 | 400 | IQ | Tất cả invalid key; sau có page/district/other; page chỉ duplicate, không thêm empty/syntax |
| GP23 | Unknown key lặp; parsed key ` page` | 400 | IQ | Unknown precedence, exposed key giữ nguyên, không echo raw value |
| GP24 | Same valid request hai lần, có/không Idempotency-Key | 200 | — | Equal JSON values, không mutate/replay header |
| GP25 | Irrelevant Authorization; missing Accept; Accept text/plain; ignored body | 200 | — | Cùng public JSON, không auth error/406/body error; test riêng |
| GP26 | Catalog fake throws với valid /places | 500 | IE | Fixed safe error; exception text/secret sentinel vắng, không real service call |
| GP27 | Eligible ID trùng; eligible id/name/category/district sai; required field null | 500 | IE | Invariant error, không malformed200; parameterize bound/name length/space/control/enum/nullability |
| GP28 | Query sai, catalog fake sẽ throw | 400 | IQ | Không gọi fake; validation trước catalog |
| GP29 | Numeric ordering fixture eligible ID [10,2,1] | 200 | — | [1,2,10], không [1,10,2] |
| GP30 | Catalog mutation kiểm soát giữa page request | 200 | — | Mỗi response coherent, không assert cross-request snapshot/no-repeat |
| GP31 | /places và category=cafe&district=q1, row10 eligible=true thiếu hours | 200 | — | ID10 không vào items/totalItems; unfiltered6, filtered[1,6]/total2, page theo tổng ấy |
| GP32 | /places và category=food&district=q3, row11 eligible=true thiếu menu | 200 | — | ID11 không vào items/totalItems; unfiltered6, filtered[5]/total1, page theo tổng ấy |

GP26 inject throwing fake qua catalog dependency của test host. Không thêm production debug endpoint, gây real database outage, gọi external API/model để sinh lỗi. Fault-demonstration commit sau này cần được phép trong nhiệm vụ và đổi implementation, không làm yếu contract/test; tác vụ này không tạo commit như vậy.
