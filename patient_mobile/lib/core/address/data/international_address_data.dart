/// Dữ liệu địa giới hành chính nhúng sẵn chuẩn xác cho các quốc gia quốc tế
/// Hỗ trợ phân cấp 3 tầng chi tiết: Tỉnh/Bang/Đô thị -> Quận/Huyện/Hạt/Thành phố -> Phường/Xã/Nhai đạo
class InternationalAddressData {
  /// Chuẩn hóa tên quốc gia để tra cứu chính xác bất kể định dạng
  static String normalizeCountry(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.contains('trung quốc') || lower.contains('china')) return 'Trung Quốc';
    if (lower.contains('hoa kỳ') || lower.contains('mỹ') || lower.contains('usa') || lower.contains('united states')) return 'Hoa Kỳ (Mỹ)';
    if (lower.contains('nhật') || lower.contains('japan')) return 'Nhật Bản';
    if (lower.contains('hàn') || lower.contains('korea')) return 'Hàn Quốc';
    if (lower.contains('đài loan') || lower.contains('taiwan')) return 'Đài Loan (Taiwan)';
    if (lower.contains('singapore')) return 'Singapore';
    if (lower.contains('úc') || lower.contains('australia')) return 'Úc (Australia)';
    if (lower.contains('anh') || lower.contains('united kingdom') || lower.contains('uk')) return 'Anh (United Kingdom)';
    if (lower.contains('pháp') || lower.contains('france')) return 'Pháp (France)';
    if (lower.contains('đức') || lower.contains('germany')) return 'Đức (Germany)';
    if (lower.contains('canada')) return 'Canada';
    if (lower.contains('thái lan') || lower.contains('thailand')) return 'Thái Lan';
    if (lower.contains('malaysia')) return 'Malaysia';
    if (lower.contains('lào') || lower.contains('laos')) return 'Lào';
    if (lower.contains('campuchia') || lower.contains('cambodia')) return 'Campuchia';
    if (lower.contains('nga') || lower.contains('russia')) return 'Nga (Russia)';
    return raw.trim();
  }

  /// Cấu trúc dữ liệu: Map<Tên Quốc Gia, Map<Tên Tỉnh/Bang, Map<Tên Quận/Huyện, List<Tên Phường/Xã>>>>
  static const Map<String, Map<String, Map<String, List<String>>>> countriesData = {
    // =========================================================================
    // 1. TRUNG QUỐC (CHINA)
    // =========================================================================
    'Trung Quốc': {
      'Thành phố Bắc Kinh (Beijing)': {
        'Quận Triều Dương (Chaoyang)': ['Nhai đạo Tam Lý Đồn (Sanlitun)', 'Nhai đạo Vọng Kinh (Wangjing)', 'Nhai đạo Á Vận Thôn (Yayuncun)', 'Nhai đạo Kiến Quốc Môn', 'Nhai đạo Triều Ngoại'],
        'Quận Hải Điện (Haidian)': ['Nhai đạo Trung Quan Thôn (Zhongguancun)', 'Nhai đạo Thanh Hoa Viên', 'Nhai đạo Yên Viên', 'Nhai đạo Vạn Thọ Lộ'],
        'Quận Tây Thành (Xicheng)': ['Nhai đạo Tây Đơn (Xidan)', 'Nhai đạo Tài Chính Nhai (Financial St.)', 'Nhai đạo Nguyệt Đàn', 'Nhai đạo Đức Thắng'],
        'Quận Đông Thành (Dongcheng)': ['Nhai đạo Vương Phủ Tỉnh (Wangfujing)', 'Nhai đạo Đông Hoa Môn', 'Nhai đạo An Định Môn', 'Nhai đạo Tiền Môn'],
        'Quận Phong Đài (Fengtai)': ['Nhai đạo Phong Đài', 'Nhai đạo Lục Lý Kiều', 'Nhai đạo Phương Trang', 'Nhai đạo Nam Uyển'],
        'Quận Thông Châu (Tongzhou)': ['Nhai đạo Bắc Uyển', 'Nhai đạo Trung Thương', 'Trấn Tống Trang', 'Trấn Đài Hồ'],
        'Quận Xương Bình (Changping)': ['Nhai đạo Thành Bắc', 'Nhai đạo Thiên Thông Uyển', 'Nhai đạo Hồi Long Quan', 'Trấn Tiểu Thang Sơn'],
        'Quận Đại Hưng (Daxing)': ['Nhai đạo Hưng Phong', 'Nhai đạo Lâm Hiệu Lộ', 'Trấn Diệc Trang (E-Town)', 'Trấn Hoàng Thôn'],
      },
      'Thành phố Thượng Hải (Shanghai)': {
        'Quận Phố Đông (Pudong)': ['Nhai đạo Lục Gia Chủy (Lujiazui)', 'Nhai đạo Trương Giang (Zhangjiang)', 'Nhai đạo Kim Kiều (Jinqiao)', 'Trấn Xuyên Sa (Chuansha)'],
        'Quận Hoàng Phố (Huangpu)': ['Nhai đạo Bến Thượng Hải (Waitan)', 'Nhai đạo Nam Kinh Đông Lộ', 'Nhai đạo Hoài Hải Trung Lộ', 'Nhai đạo Dự Viên'],
        'Quận Từ Hối (Xuhui)': ['Nhai đạo Từ Gia Hối (Xujiahui)', 'Nhai đạo Thiên Bình Lộ', 'Nhai đạo Hồ Nam Lộ', 'Nhai đạo Tào Khê'],
        'Quận Tĩnh An (Jing\'an)': ['Nhai đạo Tĩnh An Tự', 'Nhai đạo Nam Kinh Tây Lộ', 'Nhai đạo Tào Gia Độ', 'Nhai đạo Giang Ninh Lộ'],
        'Quận Mẫn Hàng (Minhang)': ['Nhai đạo Tân Trang (Xinzhuang)', 'Nhai đạo Giang Xuyên Lộ', 'Trấn Thất Bảo (Qibao)', 'Trấn Hồng Kiều (Hongqiao)'],
        'Quận Dương Phố (Yangpu)': ['Nhai đạo Ngũ Giác Trường (Wujiaochang)', 'Nhai đạo Định Hải Lộ', 'Nhai đạo Khống Giang Lộ', 'Nhai đạo Tứ Bình Lộ'],
        'Quận Hồng Khẩu (Hongkou)': ['Nhai đạo Tứ Xuyên Bắc Lộ', 'Nhai đạo Lỗ Tấn Công Viên', 'Nhai đạo Bắc Ngoại Than', 'Nhai đạo Gia Hưng Lộ'],
        'Quận Trường Ninh (Changning)': ['Nhai đạo Giang Tô Lộ', 'Nhai đạo Hoa Dương Lộ', 'Nhai đạo Tân Kinh', 'Nhai đạo Chu Gia Kiều'],
      },
      'Tỉnh Quảng Đông (Guangdong)': {
        'Thành phố Quảng Châu (Guangzhou)': ['Quận Thiên Hà (Tianhe)', 'Quận Việt Tú (Yuexiu)', 'Quận Hải Châu (Haizhu)', 'Quận Lệ Loan (Liwan)', 'Quận Phiên Ngung (Panyu)', 'Quận Bạch Vân (Baiyun)'],
        'Thành phố Thâm Quyến (Shenzhen)': ['Quận Phúc Điền (Futian)', 'Quận Nam Sơn (Nanshan)', 'Quận La Hồ (Luohu)', 'Quận Bảo An (Bao\'an)', 'Quận Long Cương (Longgang)', 'Quận Long Hoa (Longhua)'],
        'Thành phố Đông Quan (Dongguan)': ['Nhai đạo Nam Thành (Nancheng)', 'Nhai đạo Đông Thành (Dongcheng)', 'Trấn Trường An (Chang\'an)', 'Trấn Hổ Môn (Humen)'],
        'Thành phố Phật Sơn (Foshan)': ['Quận Thiền Thành (Chancheng)', 'Quận Thuận Đức (Shunde)', 'Quận Nam Hải (Nanhai)', 'Quận Tam Thủy (Sanshui)'],
        'Thành phố Chu Hải (Zhuhai)': ['Quận Hương Châu (Xiangzhou)', 'Quận Đẩu Môn (Doumen)', 'Quận Kim Loan (Jinwan)', 'Khu mới Hoành Cầm (Hengqin)'],
        'Thành phố Trung Sơn (Zhongshan)': ['Nhai đạo Thạch Kỳ (Shiqi)', 'Nhai đạo Đông Khu', 'Trấn Cổ Trấn (Guzhen)', 'Trấn Tiểu Lam (Xiaolan)'],
      },
      'Tỉnh Chiết Giang (Zhejiang)': {
        'Thành phố Hàng Châu (Hangzhou)': ['Quận Tây Hồ (Xihu)', 'Quận Thượng Thành (Shangcheng)', 'Quận Củng Thụ (Gongshu)', 'Quận Tiêu Sơn (Xiaoshan)', 'Quận Dư Hàng (Yuhang)', 'Quận Tân Giang (Binjiang)'],
        'Thành phố Ninh Ba (Ningbo)': ['Quận Hải Thự (Haishu)', 'Quận Giang Bắc (Jiangbei)', 'Quận Trấn Hải (Zhenhai)', 'Quận Ngân Châu (Yinzhou)'],
        'Thành phố Ôn Châu (Wenzhou)': ['Quận Lộc Thành (Lucheng)', 'Quận Long Loan (Longwan)', 'Quận Âu Hải (Ouhai)', 'Thành phố Thụy An (Ruian)'],
        'Thành phố Nghĩa Ô (Yiwu)': ['Nhai đạo Sầu Thành (Choucheng)', 'Nhai đạo Giang Đông (Jiangdong)', 'Nhai đạo Bắc Uyển (Beiyuan)', 'Trấn Hậu Trạch'],
      },
      'Tỉnh Giang Tô (Jiangsu)': {
        'Thành phố Nam Kinh (Nanjing)': ['Quận Huyền Vũ (Xuanwu)', 'Quận Tần Hoài (Qinhuai)', 'Quận Kiến Nghiệp (Jianye)', 'Quận Cổ Lâu (Gulou)', 'Quận Giang Ninh (Jiangning)'],
        'Thành phố Tô Châu (Suzhou)': ['Khu Công nghiệp Tô Châu (SIP)', 'Quận Cô Tô (Gusu)', 'Quận Hổ Khâu (Huqiu)', 'Quận Ngô Trung (Wuzhong)', 'Thành phố Côn Sơn (Kunshan)'],
        'Thành phố Vô Tích (Wuxi)': ['Quận Lương Khê (Liangxi)', 'Quận Tân Ngô (Xinwu)', 'Quận Tích Sơn (Xishan)', 'Thành phố Giang Âm (Jiangyin)'],
        'Thành phố Thường Châu (Changzhou)': ['Quận Chung Lâu (Zhonglou)', 'Quận Thiên Ninh (Tianning)', 'Quận Tân Bắc (Xinbei)', 'Quận Vũ Tiến (Wujin)'],
      },
      'Tỉnh Tứ Xuyên (Sichuan)': {
        'Thành phố Thành Đô (Chengdu)': ['Quận Cẩm Giang (Jinjiang)', 'Quận Thanh Dương (Qingyang)', 'Quận Kim Ngưu (Jinniu)', 'Quận Vũ Hầu (Wuhou)', 'Quận Thành Hoa (Chenghua)', 'Khu Công nghệ cao (Hi-Tech)'],
        'Thành phố Miên Dương (Mianyang)': ['Quận Phù Thành (Fucheng)', 'Quận Du Tiên (Youxian)', 'Quận An Châu (Anzhou)'],
        'Thành phố Lạc Sơn (Leshan)': ['Quận Thị Trung (Shizhong)', 'Quận Sa Vịnh (Shawan)', 'Thành phố Nga Mi Sơn (Emeishan)'],
      },
      'Tỉnh Phúc Kiến (Fujian)': {
        'Thành phố Phúc Châu (Fuzhou)': ['Quận Cổ Lâu (Gulou)', 'Quận Đài Giang (Taijiang)', 'Quận Thương Sơn (Cangshan)', 'Quận Tấn An (Jin\'an)'],
        'Thành phố Hạ Môn (Xiamen)': ['Quận Tư Minh (Siming)', 'Quận Hồ Lý (Huli)', 'Quận Tập Mỹ (Jimei)', 'Quận Hải Thương (Haicang)'],
        'Thành phố Tuyền Châu (Quanzhou)': ['Quận Lý Thành (Licheng)', 'Quận Phong Trạch (Fengze)', 'Thành phố Tấn Giang (Jinjiang)'],
      },
      'Thành phố Thiên Tân (Tianjin)': {
        'Khu vực Đô thị': ['Quận Hòa Bình (Heping)', 'Quận Hà Tây (Hexi)', 'Quận Nam Khai (Nankai)', 'Quận Hà Bắc (Hebei)'],
        'Tân khu Tân Hải (Binhai)': ['Khu Phát triển TEDA', 'Khu Cảng Thiên Tân', 'Nhai đạo Đường Cô (Tanggu)', 'Nhai đạo Đại Cảng (Dagang)'],
      },
      'Thành phố Trùng Khánh (Chongqing)': {
        'Khu vực Trung tâm': ['Quận Du Trung (Yuzhong)', 'Quận Giang Bắc (Jiangbei)', 'Quận Sa Bình Bá (Shapingba)', 'Quận Cửu Long Pha (Jiulongpo)', 'Quận Nam Ngạn (Nan\'an)'],
        'Khu vực Mở rộng': ['Quận Du Bắc (Yubei)', 'Quận Ba Nam (Banan)', 'Quận Bắc Bội (Beibei)', 'Quận Vạn Châu (Wanzhou)'],
      },
      'Đặc khu Hồng Kông (Hong Kong)': {
        'Đảo Hồng Kông': ['Quận Trung Tây (Central and Western)', 'Quận Loan Tể (Wan Chai)', 'Quận Đông (Eastern)', 'Quận Nam (Southern)'],
        'Cửu Long (Kowloon)': ['Quận Du Tiêm Vượng (Yau Tsim Mong)', 'Quận Thâm Thủy Bộ (Sham Shui Po)', 'Quận Cửu Long Thành (Kowloon City)', 'Quận Hoàng Đại Tiên', 'Quận Quan Đường'],
        'Tân Giới (New Territories)': ['Quận Sa Điền (Sha Tin)', 'Quận Đại Bộ (Tai Po)', 'Quận Nguyên Lãng (Yuen Long)', 'Quận Đồn Môn (Tuen Mun)', 'Quận Ly Đảo (Islands)'],
      },
      'Đặc khu Ma Cao (Macau)': {
        'Bán đảo Ma Cao': ['Đại Đường (Sé)', 'Vọng Đức Đường (São Lázaro)', 'Phong Thuận Đường (São Lourenço)', 'Hoa Địa Mã Đường (Nossa Senhora de Fátima)'],
        'Khu vực Đảo (Islands)': ['Đảo Đãng Tử (Taipa)', 'Đảo Lộ Hoàn (Coloane)', 'Khu Lộ Đãng Thành (Cotai Strip)'],
      },
    },

    // =========================================================================
    // 2. HOA KỲ (MỸ)
    // =========================================================================
    'Hoa Kỳ (Mỹ)': {
      'Bang California (CA)': {
        'Quận Los Angeles (LA County)': ['Thành phố Los Angeles', 'Khu Little Saigon', 'Thành phố Long Beach', 'Thành phố Glendale', 'Thành phố Pasadena'],
        'Quận Cam (Orange County)': ['Thành phố Westminster', 'Thành phố Garden Grove', 'Thành phố Santa Ana', 'Thành phố Irvine', 'Thành phố Anaheim'],
        'Quận San Diego': ['Thành phố San Diego', 'Thành phố Chula Vista', 'Thành phố Oceanside', 'Thành phố Escondido'],
        'Quận Santa Clara (Silicon Valley)': ['Thành phố San Jose', 'Thành phố Sunnyvale', 'Thành phố Santa Clara', 'Thành phố Mountain View', 'Thành phố Palo Alto'],
        'Thành phố San Francisco': ['Khu Downtown', 'Khu Sunset District', 'Khu Richmond District', 'Khu Mission District', 'Khu Chinatown'],
        'Quận Alameda': ['Thành phố Oakland', 'Thành phố Fremont', 'Thành phố Berkeley', 'Thành phố Hayward'],
        'Quận Sacramento': ['Thành phố Sacramento', 'Thành phố Elk Grove', 'Thành phố Citrus Heights', 'Thành phố Folsom'],
      },
      'Bang New York (NY)': {
        'Quận New York (Manhattan)': ['Khu Downtown / Wall St', 'Khu Midtown Manhattan', 'Khu Upper East Side', 'Khu Upper West Side', 'Khu Chinatown'],
        'Quận Kings (Brooklyn)': ['Khu Downtown Brooklyn', 'Khu Williamsburg', 'Khu Bay Ridge', 'Khu Sunset Park', 'Khu Flatbush'],
        'Quận Queens': ['Khu Flushing', 'Khu Astoria', 'Khu Long Island City', 'Khu Bayside', 'Khu Forest Hills'],
        'Quận Bronx': ['Khu South Bronx', 'Khu Riverdale', 'Khu Fordham', 'Khu Pelham Bay'],
        'Quận Richmond (Staten Island)': ['Khu St. George', 'Khu Todt Hill', 'Khu Great Kills', 'Khu Tottenville'],
        'Quận Nassau (Long Island)': ['Thị trấn Hempstead', 'Thị trấn North Hempstead', 'Thị trấn Oyster Bay'],
      },
      'Bang Texas (TX)': {
        'Quận Harris (Houston)': ['Khu Downtown Houston', 'Khu Bellaire / Chinatown', 'Khu The Heights', 'Khu Midtown', 'Thành phố Pasadena'],
        'Quận Dallas': ['Khu Downtown Dallas', 'Thành phố Garland', 'Thành phố Irving', 'Thành phố Richardson', 'Thành phố Grand Prairie'],
        'Quận Travis (Austin)': ['Khu Downtown Austin', 'Khu North Austin', 'Khu South Congress', 'Khu East Austin'],
        'Quận Bexar (San Antonio)': ['Khu Downtown San Antonio', 'Khu North Central', 'Khu Westside', 'Khu Alamo Heights'],
        'Quận Tarrant (Fort Worth)': ['Thành phố Fort Worth', 'Thành phố Arlington', 'Thành phố Mansfield', 'Thành phố Euless'],
      },
      'Bang Washington (WA)': {
        'Quận King (Seattle)': ['Khu Downtown Seattle', 'Khu Capitol Hill', 'Thành phố Bellevue', 'Thành phố Redmond', 'Thành phố Renton'],
        'Quận Pierce (Tacoma)': ['Thành phố Tacoma', 'Thành phố Lakewood', 'Thành phố Puyallup'],
        'Quận Snohomish': ['Thành phố Everett', 'Thành phố Lynnwood', 'Thành phố Edmonds'],
      },
      'Bang Florida (FL)': {
        'Quận Miami-Dade': ['Thành phố Miami', 'Thành phố Miami Beach', 'Thành phố Hialeah', 'Thành phố Coral Gables'],
        'Quận Broward': ['Thành phố Fort Lauderdale', 'Thành phố Hollywood', 'Thành phố Pembroke Pines', 'Thành phố Miramar'],
        'Quận Orange (Orlando)': ['Thành phố Orlando', 'Thành phố Winter Park', 'Thành phố Apopka'],
        'Quận Hillsborough (Tampa)': ['Thành phố Tampa', 'Thành phố Temple Terrace', 'Thành phố Plant City'],
      },
      'Bang Illinois (IL)': {
        'Quận Cook (Chicago)': ['Khu The Loop (Downtown)', 'Khu Lincoln Park', 'Khu Bridgeport / Chinatown', 'Khu Evanston'],
        'Quận DuPage': ['Thành phố Naperville', 'Thành phố Wheaton', 'Thành phố Downers Grove'],
      },
    },

    // =========================================================================
    // 3. NHẬT BẢN (JAPAN)
    // =========================================================================
    'Nhật Bản': {
      'Thủ đô Tokyo': {
        'Quận Shinjuku (Shinjuku-ku)': ['Khu Kabukicho', 'Khu Nishi-Shinjuku', 'Khu Takadanobaba', 'Khu Okubo'],
        'Quận Shibuya (Shibuya-ku)': ['Khu Dogenzaka', 'Khu Harajuku / Jingumae', 'Khu Ebisu', 'Khu Hiroo'],
        'Quận Chiyoda (Chiyoda-ku)': ['Khu Marunouchi', 'Khu Otemachi', 'Khu Akihabara (Sotokanda)', 'Khu Kanda'],
        'Quận Minato (Minato-ku)': ['Khu Roppongi', 'Khu Akasaka', 'Khu Shinbashi', 'Khu Minami-Aoyama', 'Khu Odaiba'],
        'Quận Chuo (Chuo-ku)': ['Khu Ginza', 'Khu Nihonbashi', 'Khu Tsukiji', 'Khu Kachidoki'],
        'Quận Setagaya': ['Khu Sangenjaya', 'Khu Shimokitazawa', 'Khu Futakotamagawa'],
        'Quận Taito': ['Khu Asakusa', 'Khu Ueno', 'Khu Yanaka'],
        'Thành phố Hachioji': ['Khu Trung tâm Hachioji', 'Khu Minamino', 'Khu Takao'],
      },
      'Phủ Osaka': {
        'Quận Kita (Umeda)': ['Khu Umeda', 'Khu Nakazakicho', 'Khu Dojima', 'Khu Tenjinbashi'],
        'Quận Chuo (Namba / Shinsaibashi)': ['Khu Namba', 'Khu Shinsaibashi', 'Khu Dotonbori', 'Khu Hommachi'],
        'Quận Naniwa': ['Khu Nipponbashi (Denden Town)', 'Khu Ebisuhonmachi', 'Khu Namba-naka'],
        'Quận Tennoji': ['Khu Tennoji Ekimae', 'Khu Uehommachi', 'Khu Teradacho'],
        'Thành phố Sakai': ['Quận Sakai-ku', 'Quận Naka-ku', 'Quận Kita-ku', 'Quận Minami-ku'],
      },
      'Phủ Kyoto': {
        'Quận Nakagyo (Trung tâm)': ['Khu Kawaramachi', 'Khu Karasuma', 'Khu Nijo'],
        'Quận Shimogyo (Ga Kyoto)': ['Khu Kyoto Ekimae', 'Khu Shijo-Karasuma', 'Khu Gojo'],
        'Quận Higashiyama': ['Khu Gion', 'Khu Kiyomizu', 'Khu Sanjo'],
        'Quận Sakyo': ['Khu Ginkakuji', 'Khu Demachiyanagi', 'Khu Ichijoji'],
      },
      'Tỉnh Kanagawa': {
        'Thành phố Yokohama': ['Quận Nishi-ku (Minato Mirai)', 'Quận Naka-ku (Chinatown)', 'Quận Kohoku', 'Quận Kanagawa-ku'],
        'Thành phố Kawasaki': ['Quận Kawasaki-ku', 'Quận Nakahara (Musashi-Kosugi)', 'Quận Takatsu'],
        'Thành phố Kamakura': ['Khu Kamakura Ekimae', 'Khu Hase', 'Khu Yuigahama'],
      },
      'Tỉnh Aichi': {
        'Thành phố Nagoya': ['Quận Naka-ku (Sakae)', 'Quận Nakamura-ku (Nagoya Station)', 'Quận Chikusa', 'Quận Higashi-ku'],
        'Thành phố Toyota': ['Khu Koromo', 'Khu Toyota-cho', 'Khu Sanage'],
      },
      'Tỉnh Fukuoka': {
        'Thành phố Fukuoka': ['Quận Hakata-ku (Hakata Station)', 'Quận Chuo-ku (Tenjin)', 'Quận Sawara-ku (Nishijin)', 'Quận Higashi-ku'],
        'Thành phố Kitakyushu': ['Quận Kokurakita-ku', 'Quận Kokuraminami-ku', 'Quận Yahatanishi-ku'],
      },
      'Tỉnh Hokkaido': {
        'Thành phố Sapporo': ['Quận Chuo-ku (Odori / Susukino)', 'Quận Kita-ku', 'Quận Toyohira-ku', 'Quận Shiroishi-ku'],
        'Thành phố Hakodate': ['Khu Motomachi', 'Khu Goryokaku', 'Khu Yunokawa'],
      },
    },

    // =========================================================================
    // 4. HÀN QUỐC (SOUTH KOREA)
    // =========================================================================
    'Hàn Quốc': {
      'Thủ đô Seoul': {
        'Quận Gangnam (Gangnam-gu)': ['Yeoksam-dong', 'Samseong-dong', 'Cheongdam-dong', 'Sinsa-dong (Garosugil)', 'Nonhyeon-dong', 'Daechi-dong'],
        'Quận Seocho (Seocho-gu)': ['Seocho-dong', 'Banpo-dong', 'Yangjae-dong', 'Jamwon-dong'],
        'Quận Songpa (Songpa-gu)': ['Jamsil-dong (Lotte World)', 'Bangi-dong', 'Munjeong-dong', 'Songpa-dong'],
        'Quận Mapo (Mapo-gu)': ['Seogyo-dong (Hongdae)', 'Yeonnam-dong', 'Sangam-dong (DMC)', 'Gongdeok-dong'],
        'Quận Jung (Jung-gu)': ['Myeong-dong', 'Euljiro', 'Sogong-dong', 'Hoehyeon-dong (Namdaemun)'],
        'Quận Jongno (Jongno-gu)': ['Insa-dong', 'Gwanghwamun', 'Hyehwa-dong (Daehangno)', 'Samcheong-dong'],
        'Quận Yongsan (Yongsan-gu)': ['Itaewon-dong', 'Hannam-dong', 'Yongsan-dong', 'Ichon-dong'],
        'Quận Yeongdeungpo': ['Yeouido-dong', 'Dangsan-dong', 'Mullae-dong', 'Singil-dong'],
      },
      'Thành phố Busan': {
        'Quận Haeundae (Haeundae-gu)': ['U-dong (Centum City / Marine City)', 'Jung-dong (Bãi biển Haeundae)', 'Jwa-dong', 'Songjeong-dong'],
        'Quận Busanjin (Busanjin-gu)': ['Bujeon-dong (Seomyeon)', 'Jeonpo-dong (Phố Cafe)', 'Choup-dong', 'Gaya-dong'],
        'Quận Jung (Jung-gu)': ['Nampo-dong', 'Gwangbok-dong', 'Bupyeong-dong (Chợ Kkangtong)', 'Jungang-dong'],
        'Quận Sasang': ['Gwaebeop-dong', 'Samnak-dong', 'Mora-dong'],
      },
      'Thành phố Incheon': {
        'Quận Yeonsu (Yeonsu-gu)': ['Songdo-dong (Đô thị thông minh Songdo)', 'Dongchun-dong', 'Yeonsu-dong'],
        'Quận Namdong (Namdong-gu)': ['Guwol-dong', 'Nonhyeon-dong', 'Mansu-dong'],
        'Quận Bupyeong': ['Bupyeong-dong', 'Sanggok-dong', 'Cheongcheon-dong'],
      },
      'Tỉnh Gyeonggi (Gyeonggi-do)': {
        'Thành phố Suwon': ['Quận Yeongtong-ku (Gwanggyo)', 'Quận Paldal-ku', 'Quận Jangan-ku', 'Quận Gwonseon-ku'],
        'Thành phố Seongnam': ['Quận Bundang-ku (Pangyo Techno Valley)', 'Quận Sujeong-ku', 'Quận Jungwon-ku'],
        'Thành phố Goyang': ['Quận Ilsandong-ku', 'Quận Ilsanseo-ku', 'Quận Deogyang-ku'],
        'Thành phố Yongin': ['Quận Suji-ku', 'Quận Giheung-ku', 'Quận Cheoin-ku'],
      },
      'Tỉnh tự trị Jeju (Jeju-do)': {
        'Thành phố Jeju': ['Ildo-dong', 'Iido-dong', 'Yeon-dong', 'Nohyeong-dong', 'Aewol-eup'],
        'Thành phố Seogwipo': ['Seogwi-dong', 'Jungmun-dong (Khu du lịch Jungmun)', 'Daejeong-eup', 'Seongsan-eup'],
      },
    },

    // =========================================================================
    // 5. ĐÀI LOAN (TAIWAN)
    // =========================================================================
    'Đài Loan (Taiwan)': {
      'Thành phố Đài Bắc (Taipei)': {
        'Quận Tín Nghĩa (Xinyi)': ['Khu Taipei 101', 'Tín Nghĩa Lý', 'Tam Trương Lý', 'Lục Trương Lý'],
        'Quận Đại An (Daan)': ['Đại An Lý', 'Nghĩa An Lý', 'Hòa Bình Lý', 'Vĩnh Khang Nhai (Yongkang St.)'],
        'Quận Trung Sơn (Zhongshan)': ['Trung Sơn Lý', 'Dân Sinh Lý', 'Lâm Sen Bắc Lộ', 'Đại Trực (Dazhi)'],
        'Quận Vạn Hoa (Wanhua)': ['Tây Môn Đinh (Ximending)', 'Vạn Hoa Lý', 'Long Sơn Lý', 'Hoa Tây Lý'],
        'Quận Sĩ Lâm (Shilin)': ['Khu Chợ đêm Sĩ Lâm', 'Thiên Mẫu (Tianmu)', 'Sĩ Lâm Lý', 'Xã Tử Lý'],
        'Quận Nội Hồ (Neihu)': ['Khu Công viên Khoa học Neihu', 'Nội Hồ Lý', 'Cảng Thiền Lý'],
        'Quận Tùng Sơn (Songshan)': ['Phố Nhiêu Hà (Raohe)', 'Tùng Sơn Lý', 'Dân Sinh Xã Khu'],
      },
      'Thành phố Tân Bắc (New Taipei)': {
        'Quận Bản Kiều (Banqiao)': ['Tân Bản Lý', 'Bản Kiều Lý', 'Phú Quý Lý', 'Giang Tử Thúy'],
        'Quận Trung Hòa (Zhonghe)': ['Trung Hòa Lý', 'Nam Thế Giác', 'Cảnh An Lý'],
        'Quận Tân Trang (Xinzhuang)': ['Tân Trang Lý', 'Đầu Tiền Lý', 'Phó Đô Tâm'],
        'Quận Đạm Thủy (Tamsui)': ['Phố Cổ Đạm Thủy', 'Đạm Hải Tân Thị Trấn', 'Trúc Vi Lý'],
      },
      'Thành phố Cao Hùng (Kaohsiung)': {
        'Quận Lãnh Nhã (Lingya)': ['Lãnh Nhã Lý', 'Khu Tháp 85 tầng', 'Tam Đa Thương Quyển'],
        'Quận Tân Hưng (Xinxing)': ['Khu Chợ đêm Lục Hợp', 'Tân Hưng Lý', 'Trung Đông Lý'],
        'Quận Tả Doanh (Zuoying)': ['Khu Ga Cao tốc Tả Doanh', 'Liên Trì Đàm', 'Tả Doanh Cự Đản'],
        'Quận Tiền Trấn (Qianzhen)': ['Khu Vịnh Châu Á Mới', 'Mộng Thời Đại (Dream Mall)', 'Tiền Trấn Lý'],
      },
      'Thành phố Đài Trung (Taichung)': {
        'Quận Tây Đồn (Xitun)': ['Khu Chợ đêm Phùng Giáp (Fengjia)', 'Thất Kỳ Tân Thị Trấn', 'Khu Khoa học Trung Bộ'],
        'Quận Bắc Đồn (Beitun)': ['Bắc Đồn Lý', 'Văn Tâm Lý', 'Tứ Trương Lê'],
        'Quận Trung (Central)': ['Khu Ga Đài Trung', 'Phố Cổ Đài Trung', 'Kế Quang Nhai'],
      },
    },

    // =========================================================================
    // 6. SINGAPORE
    // =========================================================================
    'Singapore': {
      'Vùng Trung tâm (Central Region)': {
        'Khu Lõi Trung tâm (Downtown Core)': ['Raffles Place', 'Marina Bay', 'City Hall', 'Bugis', 'Tanjong Pagar'],
        'Khu Mua sắm Orchard': ['Orchard Road', 'Somerset', 'Dhoby Ghaut', 'Cairnhill'],
        'Khu Bukit Merah / Chinatown': ['Chinatown', 'Tiong Bahru', 'HarbourFront', 'Telok Blangah'],
        'Khu Toa Payoh': ['Toa Payoh Central', 'Toa Payoh East', 'Toa Payoh West', 'Bishan'],
        'Khu Novena': ['Novena Central', 'Balestier', 'Moulmein', 'Thomson'],
      },
      'Vùng Phía Đông (East Region)': {
        'Khu Bedok': ['Bedok Central', 'Bedok North', 'Bedok South', 'Kaki Bukit', 'Frankel'],
        'Khu Tampines': ['Tampines Central', 'Tampines North', 'Tampines East', 'Tampines West'],
        'Khu Pasir Ris': ['Pasir Ris Central', 'Pasir Ris West', 'Loyang'],
        'Khu Changi': ['Changi Airport', 'Changi Village', 'Changi Point'],
      },
      'Vùng Phía Bắc (North Region)': {
        'Khu Woodlands': ['Woodlands Central', 'Woodlands North', 'Woodlands South', 'Marsiling'],
        'Khu Yishun': ['Yishun Central', 'Yishun North', 'Yishun East', 'Khatib'],
      },
      'Vùng Đông Bắc (North-East Region)': {
        'Khu Ang Mo Kio': ['Ang Mo Kio Town Centre', 'Cheng San', 'Chong Boon', 'Kebun Baru'],
        'Khu Hougang / Serangoon': ['Hougang Central', 'Serangoon Central', 'Kovan', 'Lorong Chuan'],
        'Khu Punggol / Sengkang': ['Punggol Town Centre', 'Waterway Point', 'Compassvale', 'Rivervale'],
      },
      'Vùng Phía Tây (West Region)': {
        'Khu Jurong East': ['Jurong Gateway', 'Toh Guan', 'International Business Park', 'Yuhua'],
        'Khu Jurong West': ['Boon Lay', 'Pioneer', 'Taman Jurong', 'Gek Poh'],
        'Khu Clementi': ['Clementi Central', 'West Coast', 'Sunset Way'],
      },
    },

    // =========================================================================
    // 7. ÚC (AUSTRALIA)
    // =========================================================================
    'Úc (Australia)': {
      'Bang New South Wales (NSW)': {
        'Thành phố Sydney (Greater Sydney)': ['Sydney CBD (Trung tâm)', 'Khu Haymarket (Chinatown)', 'Khu Pyrmont', 'Khu Surry Hills', 'Khu Bondi', 'Khu Manly'],
        'Thành phố Parramatta': ['Parramatta CBD', 'Khu Westmead', 'Khu North Parramatta', 'Khu Harris Park'],
        'Vùng Canterbury-Bankstown': ['Bankstown Central', 'Campsie', 'Punchbowl', 'Yagoona'],
        'Vùng Cumberland (Auburn / Lidcombe)': ['Auburn Central', 'Lidcombe', 'Berala', 'Regents Park'],
        'Thành phố Wollongong': ['Wollongong Central', 'North Wollongong', 'Fairy Meadow'],
      },
      'Bang Victoria (VIC)': {
        'Thành phố Melbourne (Greater Melbourne)': ['Melbourne CBD', 'Khu Carlton', 'Khu Richmond', 'Khu South Yarra', 'Khu Docklands', 'Khu St Kilda'],
        'Thành phố Monash': ['Clayton (Đại học Monash)', 'Glen Waverley', 'Mount Waverley', 'Oakleigh'],
        'Thành phố Whitehorse': ['Box Hill (Trung tâm Á Châu)', 'Mitcham', 'Blackburn', 'Nunawading'],
        'Thành phố Greater Dandenong': ['Dandenong Central', 'Springvale', 'Noble Park'],
        'Thành phố Geelong': ['Geelong Central', 'North Geelong', 'Newtown'],
      },
      'Bang Queensland (QLD)': {
        'Thành phố Brisbane': ['Brisbane CBD', 'South Brisbane', 'Fortitude Valley', 'Sunnybank (Chinatown)', 'Toowong'],
        'Thành phố Gold Coast': ['Surfers Paradise', 'Broadbeach', 'Southport', 'Robina'],
        'Thành phố Cairns': ['Cairns Central', 'Cairns North', 'Palm Cove'],
      },
      'Bang Western Australia (WA)': {
        'Thành phố Perth': ['Perth CBD', 'Northbridge (Chinatown)', 'East Perth', 'West Perth', 'Subiaco'],
        'Thành phố Fremantle': ['Fremantle Central', 'South Fremantle', 'North Fremantle'],
      },
      'Lãnh thổ Thủ đô Úc (ACT)': {
        'Thành phố Canberra': ['Civic (Canberra CBD)', 'North Canberra (Acton, Braddon)', 'South Canberra (Barton, Kingston)', 'Belconnen', 'Woden'],
      },
    },

    // =========================================================================
    // 8. ANH (UNITED KINGDOM)
    // =========================================================================
    'Anh (United Kingdom)': {
      'Đại Luân Đôn (Greater London)': {
        'Thành phố Westminster': ['Khu Soho / Covent Garden', 'Khu Mayfair', 'Khu Marylebone', 'Khu Paddington', 'Khu Victoria'],
        'Thành phố London (The City)': ['Khu Bank', 'Khu Liverpool Street', 'Khu Moorgate', 'Khu Aldgate'],
        'Quận Camden': ['Khu Camden Town', 'Khu King\'s Cross', 'Khu Holborn', 'Khu Hampstead'],
        'Quận Kensington và Chelsea': ['Khu South Kensington', 'Khu Chelsea', 'Khu Notting Hill', 'Khu Earl\'s Court'],
        'Quận Tower Hamlets': ['Khu Canary Wharf (Tài chính)', 'Khu Whitechapel', 'Khu Bethnal Green', 'Khu Wapping'],
        'Quận Greenwich': ['Khu Greenwich Town', 'Khu North Greenwich (O2)', 'Khu Woolwich'],
      },
      'Vùng Tây Bắc (North West England)': {
        'Thành phố Manchester': ['Khu Manchester City Centre', 'Khu Northern Quarter', 'Khu Ancoats', 'Khu Salford Quays', 'Khu Didsbury'],
        'Thành phố Liverpool': ['Khu City Centre', 'Khu Albert Dock', 'Khu Baltic Triangle', 'Khu Anfield'],
      },
      'Vùng West Midlands': {
        'Thành phố Birmingham': ['Khu City Centre / Bullring', 'Khu Digbeth', 'Khu Jewellery Quarter', 'Khu Edgbaston'],
        'Thành phố Coventry': ['Khu City Centre', 'Khu Earlsdon', 'Khu Canley'],
      },
      'Scotland': {
        'Thành phố Edinburgh': ['Khu Old Town', 'Khu New Town', 'Khu Leith', 'Khu Haymarket'],
        'Thành phố Glasgow': ['Khu City Centre', 'Khu West End', 'Khu Merchant City', 'Khu Southside'],
      },
    },

    // =========================================================================
    // 9. PHÁP (FRANCE)
    // =========================================================================
    'Pháp (France)': {
      'Vùng Île-de-France (Thủ đô Paris)': {
        'Thành phố Paris (Trung tâm)': ['Quận 1 (Louvre)', 'Quận 2 (Bourse)', 'Quận 3 (Temple)', 'Quận 4 (Hôtel-de-Ville / Le Marais)'],
        'Thành phố Paris (Tả ngạn Rive Gauche)': ['Quận 5 (Quartier Latin)', 'Quận 6 (Saint-Germain)', 'Quận 7 (Tour Eiffel)', 'Quận 14 (Montparnasse)'],
        'Thành phố Paris (Hữu ngạn Rive Droite)': ['Quận 8 (Champs-Élysées)', 'Quận 9 (Opéra)', 'Quận 16 (Passy)', 'Quận 18 (Montmartre)'],
        'Tỉnh Hauts-de-Seine (Ngoại ô phía Tây)': ['Thành phố Nanterre (La Défense)', 'Thành phố Boulogne-Billancourt', 'Thành phố Neuilly-sur-Seine'],
      },
      'Vùng Auvergne-Rhône-Alpes': {
        'Thành phố Lyon': ['Quận 1 (Terreaux)', 'Quận 2 (Presqu\'île)', 'Quận 3 (Part-Dieu)', 'Quận 5 (Vieux Lyon)', 'Quận 6 (Brotteaux)'],
        'Thành phố Villeurbanne': ['Khu Gratte-Ciel', 'Khu Charpennes', 'Khu Doua'],
      },
      'Vùng Provence-Alpes-Côte d\'Azur': {
        'Thành phố Marseille': ['Quận 1 (Vieux-Port)', 'Quận 2 (Joliette)', 'Quận 6 (Castellane)', 'Quận 8 (Prado)'],
        'Thành phố Nice': ['Khu Vieux-Nice', 'Khu Promenade des Anglais', 'Khu Cimiez', 'Khu Port Lympia'],
      },
    },

    // =========================================================================
    // 10. ĐỨC (GERMANY)
    // =========================================================================
    'Đức (Germany)': {
      'Bang Berlin': {
        'Quận Mitte (Trung tâm)': ['Khu Mitte', 'Khu Tiergarten', 'Khu Wedding'],
        'Quận Charlottenburg-Wilmersdorf': ['Khu Charlottenburg (Kurfürstendamm)', 'Khu Wilmersdorf', 'Khu Halensee'],
        'Quận Friedrichshain-Kreuzberg': ['Khu Kreuzberg', 'Khu Friedrichshain'],
        'Quận Pankow': ['Khu Prenzlauer Berg', 'Khu Pankow', 'Khu Weißensee'],
      },
      'Bang Bayern (Bavaria)': {
        'Thành phố München (Munich)': ['Khu Altstadt-Lehel (Trung tâm)', 'Khu Ludwigsvorstadt-Isarvorstadt', 'Khu Maxvorstadt', 'Khu Schwabing', 'Khu Bogenhausen'],
        'Thành phố Nürnberg': ['Khu Altstadt', 'Khu Gostenhof', 'Khu Südstadt'],
      },
      'Bang Nordrhein-Westfalen': {
        'Thành phố Köln (Cologne)': ['Khu Innenstadt (Nhà thờ Dom)', 'Khu Ehrenfeld', 'Khu Lindenthal', 'Khu Deutz'],
        'Thành phố Düsseldorf': ['Khu Altstadt', 'Khu Stadtmitte (Khu Little Tokyo)', 'Khu Unterbilk (MedienHafen)'],
      },
      'Bang Hessen': {
        'Thành phố Frankfurt am Main': ['Khu Innenstadt (Trung tâm Tài chính)', 'Khu Altstadt', 'Khu Westend', 'Khu Sachsenhausen', 'Khu Bornheim'],
      },
    },

    // =========================================================================
    // 11. CANADA
    // =========================================================================
    'Canada': {
      'Bang Ontario': {
        'Thành phố Toronto': ['Khu Downtown Toronto', 'Khu North York', 'Khu Scarborough', 'Khu Etobicoke', 'Khu Yorkville'],
        'Thành phố Ottawa': ['Khu Downtown Ottawa', 'Khu Centretown', 'Khu Kanata', 'Khu Nepean', 'Khu Orleans'],
        'Thành phố Mississauga': ['Khu City Centre (Square One)', 'Khu Port Credit', 'Khu Streetsville'],
      },
      'Bang Quebec': {
        'Thành phố Montreal': ['Khu Ville-Marie (Downtown)', 'Khu Plateau-Mont-Royal', 'Khu Côte-des-Neiges', 'Khu Saint-Laurent'],
        'Thành phố Quebec': ['Khu Vieux-Québec (Phố cổ)', 'Khu Sainte-Foy', 'Khu Saint-Roch'],
      },
      'Bang British Columbia (BC)': {
        'Thành phố Vancouver': ['Khu Downtown Vancouver', 'Khu West End', 'Khu Kitsilano', 'Khu Mount Pleasant', 'Khu Yaletown'],
        'Thành phố Richmond': ['Khu Richmond City Centre', 'Khu Steveston', 'Khu Broadmoor'],
        'Thành phố Burnaby': ['Khu Metrotown', 'Khu Brentwood', 'Khu Lougheed'],
      },
      'Bang Alberta': {
        'Thành phố Calgary': ['Khu Downtown Calgary', 'Khu Beltline', 'Khu Kensington', 'Khu Northwest'],
        'Thành phố Edmonton': ['Khu Downtown Edmonton', 'Khu Strathcona (Whyte Ave)', 'Khu West Edmonton'],
      },
    },

    // =========================================================================
    // 12. THÁI LAN (THAILAND)
    // =========================================================================
    'Thái Lan': {
      'Thủ đô Bangkok (Krung Thep)': {
        'Quận Phra Nakhon (Phố cổ)': ['Khwaeng San Chao Pho Suea', 'Khwaeng Phra Borom Maha Ratchawang', 'Khwaeng Chana Songkhram (Khaosan)'],
        'Quận Pathum Wan (Siam)': ['Khwaeng Rong Mueang', 'Khwaeng Wang Mai', 'Khwaeng Pathum Wan', 'Khwaeng Lumphini'],
        'Quận Bang Rak (Silom)': ['Khwaeng Si Lom', 'Khwaeng Suriyawong', 'Khwaeng Maha Phruettharam'],
        'Quận Watthana (Sukhumvit)': ['Khwaeng Khlong Toei Nuea', 'Khwaeng Khlong Tan Nuea', 'Khwaeng Phra Khanong Nuea (Thong Lo)'],
        'Quận Chatuchak': ['Khwaeng Chatuchak', 'Khwaeng Chomphon', 'Khwaeng Chan Kasem'],
      },
      'Tỉnh Chiang Mai': {
        'Huyện Mueang Chiang Mai': ['Tambon Si Phum (Thành cổ)', 'Tambon Chang Moi', 'Tambon Chang Khlan (Night Bazaar)', 'Tambon Suthep (Nimman)'],
        'Huyện Hang Dong': ['Tambon Hang Dong', 'Tambon Nong Kwai', 'Tambon Ban Waen'],
      },
      'Tỉnh Phuket': {
        'Huyện Mueang Phuket': ['Tambon Talat Yai (Phố cổ Phuket)', 'Tambon Talat Nuea', 'Tambon Rawai', 'Tambon Chalong'],
        'Huyện Kathu': ['Tambon Pa Tong (Bãi biển Patong)', 'Tambon Kathu', 'Tambon Kamala'],
      },
      'Tỉnh Chonburi (Pattaya)': {
        'Thành phố Pattaya (Bang Lamung)': ['Tambon Nong Prue', 'Tambon Na Kluea', 'Tambon Nong Pla Lai'],
        'Huyện Si Racha': ['Tambon Si Racha', 'Tambon Surasak', 'Tambon Thung Sukhla'],
      },
    },

    // =========================================================================
    // 13. MALAYSIA
    // =========================================================================
    'Malaysia': {
      'Wilayah Persekutuan Kuala Lumpur': {
        'Khu vực Bukit Bintang': ['Khu Bukit Bintang Central', 'Khu Imbi', 'Khu Pudu', 'Khu Jalan Alor'],
        'Khu vực KLCC (Trung tâm)': ['Khu Tháp Đôi Petronas', 'Khu Jalan Ampang', 'Khu Dang Wangi'],
        'Khu vực Bangsar': ['Khu Bangsar Baru', 'Khu Lucky Garden', 'Khu Bukit Bandaraya'],
        'Khu vực Mont Kiara': ['Khu Mont Kiara Central', 'Khu Sri Hartamas', 'Khu Dutamas'],
      },
      'Bang Selangor': {
        'Thành phố Petaling Jaya': ['Khu Damansara Utama (Uptown)', 'Khu SS2', 'Khu Bandar Utama', 'Khu Kota Damansara'],
        'Thành phố Subang Jaya': ['Khu SS15', 'Khu USJ', 'Khu Bandar Sunway (Sunway Pyramid)'],
        'Thành phố Shah Alam': ['Seksyen 1 - 7 (Trung tâm)', 'Seksyen 13', 'Khu Setia Alam'],
      },
      'Bang Pulau Pinang (Penang)': {
        'Thành phố George Town': ['Khu Phố Cổ Di sản', 'Khu Gurney Drive', 'Khu Pulau Tikus', 'Khu Tanjung Tokong'],
        'Thành phố Bayan Lepas': ['Khu Công nghệ cao FIZ', 'Khu Sungai Ara', 'Khu Batu Maung'],
      },
      'Bang Johor': {
        'Thành phố Johor Bahru': ['Khu JB City Centre', 'Khu Danga Bay', 'Khu Taman Mount Austin', 'Khu Iskandar Puteri'],
      },
    },

    // =========================================================================
    // 14. LÀO (LAOS)
    // =========================================================================
    'Lào': {
      'Thủ đô Viêng Chăn (Vientiane Pref.)': {
        'Huyện Chanthabuly (Trung tâm)': ['Bản Hatsady', 'Bản Sihom', 'Bản Mixay', 'Bản Anou', 'Bản Khua Luang'],
        'Huyện Sikhottabong': ['Bản Nongteh', 'Bản Wattay (Sân bay)', 'Bản Oupmoung'],
        'Huyện Xaysetha': ['Bản That Luang (Thạt Luổng)', 'Bản Phonxay', 'Bản Nongbone'],
        'Huyện Sisattanak': ['Bản Dongpalan', 'Bản Thaphalanxay', 'Bản Sokpaluang'],
      },
      'Tỉnh Luang Prabang': {
        'Huyện Luang Prabang': ['Bản Phố Cổ Trung Tâm', 'Bản Xieng Thong', 'Bản Vat Nong', 'Bản Mano'],
        'Huyện Xiengngeun': ['Bản Xiengngeun', 'Bản Pakxeng'],
      },
      'Tỉnh Champasak': {
        'Thành phố Pakse': ['Bản Pakse Trung Tâm', 'Bản Thaluang', 'Bản Sanamxay'],
        'Huyện Champassack': ['Bản Wat Phou', 'Bản Muang Kao'],
      },
    },

    // =========================================================================
    // 15. CAMPUCHIA (CAMBODIA)
    // =========================================================================
    'Campuchia': {
      'Thủ đô Phnôm Pênh (Phnom Penh)': {
        'Quận Doun Penh (Trung tâm)': ['Sangkat Phsar Kandal', 'Sangkat Phsar Thmey (Chợ Lớn)', 'Sangkat Voat Phnum', 'Sangkat Chey Chumneah (Cung điện)'],
        'Quận Chamkar Mon': ['Sangkat Tonle Basak', 'Sangkat Tuol Tumpung (Chợ Nga)', 'Sangkat Phsar Daeum Thkov'],
        'Quận Boeng Keng Kang': ['Sangkat Boeng Keng Kang 1 (BKK1)', 'Sangkat Boeng Keng Kang 2', 'Sangkat Boeng Keng Kang 3'],
        'Quận Tuol Kouk': ['Sangkat Boeng Kak 1', 'Sangkat Boeng Kak 2', 'Sangkat Phsar Depou'],
        'Quận Sen Sok': ['Sangkat Phnom Penh Thmei (AEON Mall 2)', 'Sangkat Teuk Thla'],
      },
      'Tỉnh Xiêm Riệp (Siem Reap)': {
        'Thành phố Siem Reap': ['Sangkat Svay Dangkum (Pub Street)', 'Sangkat Sala Kamreuk', 'Sangkat Kouk Chak (Angkor)', 'Sangkat Slor Kram'],
        'Huyện Prasat Bakong': ['Khum Bakong', 'Khum Roluos'],
      },
      'Tỉnh Preah Sihanouk (Kompong Som)': {
        'Thành phố Sihanoukville': ['Sangkat 1', 'Sangkat 2', 'Sangkat 3', 'Sangkat 4 (Khu Cảng)'],
      },
    },

    // =========================================================================
    // 16. NGA (RUSSIA)
    // =========================================================================
    'Nga (Russia)': {
      'Thành phố Moscow (Mát-xcơ-va)': {
        'Quận Trung tâm (Tsentralny)': ['Huyện Tverskoy (Điện Kremlin)', 'Huyện Arbat', 'Huyện Basmanny', 'Huyện Khamovniki', 'Huyện Zamoskvorechye'],
        'Quận Tây (Zapadny)': ['Huyện Dorogomilovo (Moscow City)', 'Huyện Ramenki (Đại học MGU)', 'Huyện Fili'],
        'Quận Bắc (Severny)': ['Huyện Aeroport', 'Huyện Begovoy', 'Huyện Sokol'],
        'Quận Nam (Yuzhny)': ['Huyện Danilovsky', 'Huyện Donskoy', 'Huyện Nagatino'],
      },
      'Thành phố Saint Petersburg': {
        'Quận Trung tâm (Tsentralny)': ['Khu Quảng trường Cung điện', 'Khu Đại lộ Nevsky', 'Khu Smolninskoye'],
        'Quận Petrogradsky': ['Khu Pháo đài Peter & Paul', 'Khu Aptekarsky', 'Khu Chkalovskoye'],
        'Quận Vasileostrovsky': ['Khu Đảo Vasilyevsky', 'Khu Morskoy', 'Khu Gavan'],
      },
      'Tỉnh Novosibirsk': {
        'Thành phố Novosibirsk': ['Quận Leninsky', 'Quận Tsentralny', 'Quận Dzerzhinsky', 'Khu Akademgorodok (Thị trấn Khoa học)'],
      },
      'Cộng hòa Tatarstan': {
        'Thành phố Kazan': ['Quận Vakhitovsky (Điện Kazan Kremlin)', 'Quận Privolzhsky', 'Quận Sovetsky', 'Quận Novo-Savinovsky'],
      },
    },
  };

  /// Lấy danh sách Tỉnh/Bang của quốc gia
  static List<String> getProvinces(String rawCountry) {
    final country = normalizeCountry(rawCountry);
    final countryMap = countriesData[country];
    if (countryMap != null && countryMap.isNotEmpty) {
      return countryMap.keys.toList();
    }
    // Dự phòng mặc định nếu quốc gia chưa có trong bộ dữ liệu
    return [
      'Khu vực Trung tâm (Central)',
      'Vùng Phía Bắc (North)',
      'Vùng Phía Nam (South)',
      'Vùng Phía Đông (East)',
      'Vùng Phía Tây (West)',
    ];
  }

  /// Lấy danh sách Quận/Huyện của Tỉnh/Bang
  static List<String> getDistricts(String rawCountry, String provinceName) {
    final country = normalizeCountry(rawCountry);
    final countryMap = countriesData[country];
    if (countryMap != null) {
      // Tìm tỉnh chính xác hoặc gần đúng
      final provEntry = countryMap.entries.firstWhere(
        (e) => e.key == provinceName || e.key.contains(provinceName) || provinceName.contains(e.key),
        orElse: () => countryMap.entries.first,
      );
      return provEntry.value.keys.toList();
    }
    return [
      'Quận Trung tâm (Central District)',
      'Quận 1 (District 1)',
      'Quận 2 (District 2)',
      'Thị trấn / Khu phố',
      'Hạt ngoại ô',
    ];
  }

  /// Lấy danh sách Phường/Xã/Nhai đạo của Quận/Huyện
  static List<String> getWards(String rawCountry, String districtName) {
    final country = normalizeCountry(rawCountry);
    final countryMap = countriesData[country];
    if (countryMap != null) {
      for (final prov in countryMap.values) {
        for (final dist in prov.entries) {
          if (dist.key == districtName || dist.key.contains(districtName) || districtName.contains(dist.key)) {
            if (dist.value.isNotEmpty) {
              return dist.value;
            }
          }
        }
      }
    }

    // Dự phòng tự động thông minh theo phong cách địa lý của quốc gia
    if (country.contains('Trung Quốc')) {
      return ['Nhai đạo Trung tâm', 'Nhai đạo Nhân Dân', 'Nhai đạo Tân Hoa', 'Nhai đạo Hòa Bình', 'Trấn Trung Tâm'];
    }
    if (country.contains('Hoa Kỳ') || country.contains('Canada') || country.contains('Úc') || country.contains('Anh')) {
      return ['Khu Trung tâm (Downtown / Central)', 'Khu Phía Bắc (North Sector)', 'Khu Phía Nam (South Sector)', 'Khu Dân cư Đông (East Park)'];
    }
    if (country.contains('Nhật Bản')) {
      return ['1-Chome (Chome 1)', '2-Chome (Chome 2)', '3-Chome (Chome 3)', 'Honcho (Khu phố chính)', 'Khu Ekimae'];
    }
    if (country.contains('Hàn Quốc')) {
      return ['1-dong (Phường 1)', '2-dong (Phường 2)', 'Jungang-dong (Phường Trung tâm)', 'Samil-dong'];
    }
    return [
      'Phường / Tiểu khu 1',
      'Phường / Tiểu khu 2',
      'Phường Trung tâm',
      'Khu dân cư số 1',
    ];
  }
}
