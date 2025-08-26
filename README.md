# Naspend - Sổ Thu Chi Cá Nhân

**Naspend** là một ứng dụng Flutter mã nguồn mở, được xây dựng để giúp người dùng quản lý tài chính cá nhân một cách đơn giản và hiệu quả. Ứng dụng cho phép theo dõi các khoản thu nhập và chi tiêu hàng ngày, cung cấp cái nhìn tổng quan qua các báo cáo và biểu đồ trực quan.

Đây là một dự án cá nhân được phát triển nhằm thể hiện kỹ năng xây dựng một ứng dụng Flutter hoàn chỉnh, từ giao diện người dùng, quản lý trạng thái, đến lưu trữ dữ liệu cục bộ.

## Demo & Hình ảnh ứng dụng

| Dashboard | Lịch Giao Dịch | Ghi Chép Giao Dịch |
| :---: | :---: | :---: |
| <img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/625a3ed1-2514-4c73-b093-10c7cd875d77" /> | <img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/7538b2de-e76b-441c-bf4f-d2571269b695" /> | <img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/ae031c1e-c960-4ece-89d0-818517fd3e14" /> |

| Quản lý Danh mục | Cài đặt |
| :---: | :---: |
| <img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/0f32679b-d70c-499c-91d2-cb6eb1ebadd2" /> | <img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/b57c9e07-4591-4b02-afcb-b0c2e750c737" /> |

## Tính năng chính

-   **Ghi chép Giao dịch:** Dễ dàng thêm các khoản thu nhập và chi tiêu với số tiền, danh mục, ghi chú và ngày tháng.
-   **Quản lý theo Danh mục:**
    -   Tạo, sửa, xóa các danh mục thu/chi.
    -   Tùy chỉnh icon và màu sắc cho từng danh mục.
    -   Áp dụng cơ chế **"Xóa mềm" (Soft Delete)**, giúp giữ lại dữ liệu lịch sử của các giao dịch ngay cả khi danh mục liên quan đã bị xóa.
-   **Thống kê Trực quan:**
    -   Bảng điều khiển (Dashboard) hiển thị tổng thu, tổng chi và số dư trong tháng.
    -   Biểu đồ tròn (`Pie Chart`) phân tích tỷ trọng chi tiêu/thu nhập theo từng danh mục.
-   **Lịch Giao dịch:**
    -   Xem tổng quan thu/chi trực tiếp trên lịch.
    -   Chạm để xem chi tiết và cuộn đến danh sách giao dịch của ngày được chọn.
-   **Cài đặt & Tiện ích:**
    -   Thiết lập nhắc nhở ghi chép hàng ngày vào một thời điểm tùy chỉnh.
    -   Tùy chọn xóa toàn bộ dữ liệu để bắt đầu lại.

## Kiến trúc & Công nghệ sử dụng

Dự án được xây dựng theo kiến trúc **MVVM (Model-View-ViewModel)** để đảm bảo sự phân tách rõ ràng giữa giao diện và logic nghiệp vụ, giúp mã nguồn trở nên sạch sẽ, dễ bảo trì và mở rộng.

-   **Ngôn ngữ:** Dart
-   **Framework:** Flutter

### Các thành phần chính:

-   **Quản lý Trạng thái (State Management):**
    -   **Provider:** Được sử dụng để Dependency Injection và quản lý trạng thái của các màn hình, giúp tách biệt hoàn toàn logic ra khỏi UI.

-   **Lưu trữ Dữ liệu (Data Persistence):**
    -   **Drift (trên nền SQLite):** Sử dụng làm cơ sở dữ liệu cục bộ. Drift cung cấp một hệ thống truy vấn an toàn kiểu (type-safe) và phản ứng (reactive) mạnh mẽ, tự động cập nhật UI khi dữ liệu thay đổi.
    -   **SharedPreferences:** Dùng để lưu các cài đặt đơn giản của người dùng như trạng thái bật/tắt thông báo.

-   **Điều hướng (Navigation):**
    -   **GoRouter:** Xây dựng một hệ thống điều hướng tập trung, khai báo (declarative), giúp quản lý các route trong ứng dụng một cách mạch lạc.

-   **Lập trình Bất đồng bộ & Phản ứng (Async & Reactive Programming):**
    -   **Stream / Future:** Tận dụng tối đa sức mạnh của Dart để xử lý các tác vụ bất đồng bộ và xây dựng giao diện người dùng có khả năng tự cập nhật (reactive UI).
    -   **RxDart:** Sử dụng để kết hợp và xử lý các luồng dữ liệu (Stream) phức tạp một cách hiệu quả.

-   **Giao diện & Trải nghiệm người dùng (UI/UX):**
    -   **Material 3:** Thiết kế theo chuẩn mới nhất của Google.
    -   **`syncfusion_flutter_charts`:** Để tạo các biểu đồ tròn thống kê chuyên nghiệp.
    -   **`table_calendar`:** Xây dựng giao diện lịch tùy chỉnh và mạnh mẽ.
    -   **`intl`:** Định dạng số, tiền tệ và ngày tháng theo chuẩn Việt Nam.

-   **Thông báo (Notifications):**
    -   **`flutter_local_notifications`:** Lên lịch và hiển thị các thông báo nhắc nhở hàng ngày ngay trên thiết bị.

## Cài đặt & Chạy dự án

1.  **Clone a repository:**
    ```sh
    git clone [https://github.com/hellonamdeptrai/Naspend.git](https://github.com/hellonamdeptrai/Naspend.git)
    cd naspend
    ```
2.  **Cài đặt các dependencies:**
    ```sh
    flutter pub get
    ```
3.  **Tạo mã nguồn cho Drift (quan trọng):**
    Do dự án sử dụng Drift, bạn cần chạy lệnh sau để tạo các file `.g.dart` cần thiết.
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Chạy ứng dụng:**
    ```sh
    flutter run
    ```

## Hướng phát triển trong tương lai

-   [ ] Đồng bộ dữ liệu lên đám mây (Firebase Firestore, Supabase).
-   [ ] Hỗ trợ nhiều tài khoản/ví tiền.
-   [ ] Chức năng lập ngân sách (Budgeting) và đặt mục tiêu tiết kiệm.
-   [ ] Xuất dữ liệu ra file CSV/PDF.
-   [ ] Hỗ trợ đa ngôn ngữ.

---

Cảm ơn bạn đã xem qua dự án! Mọi ý kiến đóng góp xin vui lòng liên hệ.