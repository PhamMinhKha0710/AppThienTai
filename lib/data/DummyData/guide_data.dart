import 'package:cuutrobaolu/presentation/features/home/models/guide_model.dart';
import 'package:iconsax/iconsax.dart';

class GuideData {
  static final List<GuideModel> guides = [
    GuideModel(
      id: '1',
      title: 'Kỹ năng sinh tồn khi có Bão',
      category: 'Bão',
      icon: 'assets/icons/storm.png',
      content: '''
# Kỹ Năng Ứng Phó Khi Có Bão

## 1. Trước khi bão đến
- **Cập nhật tin tức**: Thường xuyên theo dõi dự báo thời tiết qua TV, radio, hoặc ứng dụng.
- **Gia cố nhà cửa**: Chằng chống mái nhà, cửa sổ, cửa ra vào. Cắt tỉa cành cây lớn quanh nhà.
- **Chuẩn bị đồ dự trữ**:
  - Nước uống & thực phẩm khô (mì gói, lương khô) đủ cho 3-5 ngày.
  - Đèn pin, pin dự phòng, nến, diêm.
  - Túi sơ cứu y tế.
  - Sạc đầy điện thoại và sạc dự phòng.
- **Sơ tán**: Nếu ở vùng trũng thấp hoặc nhà không an toàn, hãy di dời đến nơi trú ẩn an toàn theo chỉ dẫn của chính quyền.

## 2. Trong khi bão đổ bộ
- **Ở trong nhà**: Tuyệt đối không ra ngoài khi mưa to gió lớn. Tránh xa cửa sổ, cửa kính.
- **Cắt điện**: Cắt cầu dao điện nếu khu vực bị ngập nước hoặc có nguy cơ chập cháy.
- **Giữ liên lạc**: Giữ liên lạc với người thân và chính quyền (nếu cần trợ giúp khẩn cấp).

## 3. Sau khi bão tan
- **Kiểm tra an toàn**: Chỉ ra ngoài khi có thông báo an toàn. Chú ý dây điện rơi, cây đổ.
- **Vệ sinh môi trường**: Dọn dẹp nhà cửa, xử lý xác động vật, khơi thông cống rãnh để phòng dịch bệnh.
- **Kiểm tra nguồn nước**: Đun sôi nước trước khi uống.
''',
    ),
    GuideModel(
      id: '2',
      title: 'Kỹ năng ứng phó với Lũ lụt',
      category: 'Lũ',
      icon: 'assets/icons/flood.png',
      content: '''
# Kỹ Năng Ứng Phó Khi Có Lũ Lụt

## 1. Chuẩn bị
- Kê cao đồ đạc, thiết bị điện.
- Chuẩn bị phao cứu sinh, bè mảng (nếu có thể).
- Xác định điểm sơ tán gần nhất.

## 2. Khi lũ về
- Ngắt nguồn điện toàn bộ ngôi nhà.
- Không lội qua dòng nước chảy xiết (nước ngập trên mắt cá chân có thể làm bạn ngã).
- Không lái xe vào vùng ngập nước.
- Nếu nước dâng cao, hãy di chuyển lên chỗ cao hơn (mái nhà) và ra tín hiệu cầu cứu.

## 3. Hậu quả
- Không dùng thực phẩm đã tiếp xúc với nước lũ.
- Vệ sinh nhà cửa bằng dung dịch khử trùng.
''',
    ),
    GuideModel(
      id: '3',
      title: 'Sơ cứu cơ bản: Đuối nước',
      category: 'Sơ cứu',
      icon: 'assets/icons/health.png',
      content: '''
# Sơ Cứu Người Bị Đuối Nước

1. **Đưa nạn nhân ra khỏi nước**: Nhanh chóng nhưng phải đảm bảo an toàn cho bản thân. Dùng sào, dây hoặc phao ném cho nạn nhân.
2. **Kiểm tra phản ứng**:
   - Gọi to, vỗ nhẹ vào vai.
   - Nếu không phản ứng, kiểm tra hơi thở (nhìn lồng ngực di động).
3. **Hô hấp nhân tạo (CPR)**:
   - Nếu nạn nhân **ngừng thở**: Thực hiện ép tim ngoài lồng ngực ngay lập tức.
   - Tỷ lệ: 30 lần ép tim / 2 lần thổi ngạt.
   - Tiếp tục cho đến khi nạn nhân tự thở được hoặc nhân viên y tế đến.
4. **Ủ ấm**: Khi nạn nhân tỉnh, thay quần áo khô và ủ ấm. Đưa đến cơ sở y tế gần nhất.
''',
    ),
      GuideModel(
      id: '4',
      title: 'Chuẩn bị Túi Khẩn Cấp (Go Bag)',
      category: 'Chuẩn bị',
      icon: 'assets/icons/bag.png',
      content: '''
# Danh Mục Túi Khẩn Cấp (Go Bag)
*Hãy chuẩn bị sẵn một túi ba lô chống nước cho mỗi thành viên.*

1. **Nước uống**: Tối thiểu 2 lít/người.
2. **Thực phẩm**: Lương khô, đồ hộp, chocolate (năng lượng cao).
3. **Y tế**: Bông băng, thuốc sát trùng, thuốc tiêu hóa, thuốc hạ sốt, thuốc cá nhân.
4. **Dụng cụ**: Đèn pin, dao đa năng, bật lửa, còi cứu hộ.
5. **Giấy tờ**: Bản sao CCCD, BHYT, giấy tờ nhà đất (đựng trong túi nhựa kín).
6. **Tiền mặt**: Một ít tiền mặt mệnh giá nhỏ.
7. **Quần áo**: 1 bộ quần áo khô, áo mưa mỏng.
''',
    ),
  ];
}
