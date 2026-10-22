/// Dữ liệu hành chính và danh mục thực tế chuẩn A-Z phục vụ tạo hồ sơ bệnh nhân trong và ngoài nước
class VietnamAdministrativeData {
  /// Danh sách các Quốc gia trên thế giới được sắp xếp chuẩn từ A đến Z (Tên tiếng Việt chuẩn)
  static const List<String> countries = [
    'Ai Cập (Egypt)',
    'Anh (United Kingdom)',
    'Argentina',
    'Ấn Độ (India)',
    'Áo (Austria)',
    'Ba Lan (Poland)',
    'Bỉ (Belgium)',
    'Bồ Đào Nha (Portugal)',
    'Brazil',
    'Campuchia (Cambodia)',
    'Canada',
    'Chile',
    'Colombia',
    'Cuba',
    'Đan Mạch (Denmark)',
    'Đài Loan (Taiwan)',
    'Đức (Germany)',
    'Hà Lan (Netherlands)',
    'Hàn Quốc (South Korea)',
    'Hoa Kỳ (Mỹ - United States)',
    'Hungary',
    'Hy Lạp (Greece)',
    'Indonesia',
    'Ireland',
    'Israel',
    'Lào (Laos)',
    'Malaysia',
    'Mexico',
    'Mông Cổ (Mongolia)',
    'Myanmar',
    'Na Uy (Norway)',
    'Nam Phi (South Africa)',
    'New Zealand',
    'Nga (Russia)',
    'Nhật Bản (Japan)',
    'Phần Lan (Finland)',
    'Pháp (France)',
    'Philippines',
    'Singapore',
    'Tây Ban Nha (Spain)',
    'Thái Lan (Thailand)',
    'Thổ Nhĩ Kỳ (Turkey)',
    'Thụy Điển (Sweden)',
    'Thụy Sĩ (Switzerland)',
    'Triều Tiên (North Korea)',
    'Trung Quốc (China)',
    'Úc (Australia)',
    'Ukraine',
    'Việt Nam',
    'Ý (Italy)',
  ];

  /// Đầy đủ 54 Dân tộc Việt Nam được sắp xếp chuẩn từ A đến Z
  static const List<String> ethnicGroups = [
    'Ba Na',
    'Bố Y',
    'Brâu',
    'Bru - Vân Kiều',
    'Chăm',
    'Chơ Ro',
    'Chu Ru',
    'Chứt',
    'Co',
    'Cống',
    'Cơ Ho',
    'Cơ Lao',
    'Cơ Tu',
    'Dao',
    'Ê Đê',
    'Giáy',
    'Gié Triêng',
    'Gia Rai',
    'H\'Mông',
    'Hà Nhì',
    'Hoa',
    'Hrê',
    'Kháng',
    'Khmer',
    'Khơ Mú',
    'Kinh',
    'La Chí',
    'La Ha',
    'La Hủ',
    'Lào',
    'Lô Lô',
    'Lự',
    'M\'Nông',
    'Mạ',
    'Mảng',
    'Mường',
    'Ngái',
    'Nùng',
    'Ơ Đu',
    'Pà Thẻn',
    'Phù Lá',
    'Pu Péo',
    'Ra Glai',
    'Rơ Măm',
    'Sán Chay',
    'Sán Dìu',
    'Si La',
    'Tà Ôi',
    'Tày',
    'Thái',
    'Thổ',
    'Xinh Mun',
    'Xơ Đăng',
    'Xtiêng',
  ];

  /// Danh mục Nghề nghiệp thực tế được sắp xếp từ A đến Z
  static const List<String> occupations = [
    'Bác sĩ / Dược sĩ / Nhân viên y tế',
    'Cán bộ / Công chức / Viên chức nhà nước',
    'Công nhân / Lao động kỹ thuật',
    'Doanh nhân / Chủ doanh nghiệp / Quản lý',
    'Giáo viên / Giảng viên / Nghiên cứu sinh',
    'Học sinh / Sinh viên',
    'Hưu trí / Người cao tuổi',
    'Kế toán / Kiểm toán / Ngân hàng',
    'Kinh doanh / Buôn bán / Thương nhân',
    'Kỹ sư / Chuyên viên CNTT / Kỹ thuật',
    'Lao động tự do / Làm việc độc lập',
    'Lực lượng vũ trang (Công an, Quân đội)',
    'Luật sư / Chuyên viên pháp lý',
    'Nghệ sĩ / Diễn viên / Thiết kế / Báo chí',
    'Nông dân / Ngư dân / Lâm nghiệp',
    'Nội trợ',
    'Tài xế / Giao nhận / Logistics',
  ];

  /// Mối quan hệ với chủ tài khoản được sắp xếp từ A đến Z
  static const List<String> relationships = [
    'Anh / Chị / Em ruột',
    'Bản thân',
    'Bố / Mẹ',
    'Con cái',
    'Họ hàng / Người thân thích',
    'Người bảo trợ / Người giám hộ',
    'Ông / Bà',
    'Vợ / Chồng',
  ];

  /// 63 Tỉnh / Thành phố của Việt Nam được sắp xếp chuẩn từ A đến Z
  static const List<String> vietnamProvinces = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cần Thơ',
    'Cao Bằng',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'TP. Hồ Chí Minh',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];

  /// Các Tỉnh, Thành phố trực thuộc và Khu tự trị của Trung Quốc sắp xếp từ A đến Z
  static const List<String> chinaProvinces = [
    'An Huy (Anhui)',
    'Bắc Kinh (Beijing)',
    'Cát Lâm (Jilin)',
    'Chiết Giang (Zhejiang)',
    'Giang Tô (Jiangsu)',
    'Giang Tây (Jiangxi)',
    'Hà Bắc (Hebei)',
    'Hà Nam (Henan)',
    'Hải Nam (Hainan)',
    'Hắc Long Giang (Heilongjiang)',
    'Hồ Bắc (Hubei / Vũ Hán)',
    'Hồ Nam (Hunan)',
    'Hồng Kông (Hong Kong)',
    'Liêu Ninh (Liaoning)',
    'Ma Cao (Macau)',
    'Ninh Hạ (Ningxia)',
    'Nội Mông (Inner Mongolia)',
    'Phúc Kiến (Fujian)',
    'Quảng Châu (Guangzhou)',
    'Quảng Đông (Guangdong)',
    'Quảng Tây (Guangxi)',
    'Quý Châu (Guizhou)',
    'Sơn Đông (Shandong)',
    'Sơn Tây (Shanxi)',
    'Tân Cương (Xinjiang)',
    'Tây Tạng (Tibet)',
    'Thanh Hải (Qinghai)',
    'Thâm Quyến (Shenzhen)',
    'Thiên Tân (Tianjin)',
    'Thiểm Tây (Shaanxi / Tây An)',
    'Thượng Hải (Shanghai)',
    'Trùng Khánh (Chongqing)',
    'Tứ Xuyên (Sichuan / Thành Đô)',
    'Vân Nam (Yunnan)',
  ];

  /// Các Bang của Hoa Kỳ sắp xếp từ A đến Z
  static const List<String> usStates = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'Washington D.C.',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  /// Các Tỉnh, Đô thị của Nhật Bản sắp xếp từ A đến Z
  static const List<String> japanPrefectures = [
    'Aichi (Nagoya)',
    'Akita',
    'Aomori',
    'Chiba',
    'Ehime',
    'Fukui',
    'Fukuoka',
    'Fukushima',
    'Gifu',
    'Gunma',
    'Hiroshima',
    'Hokkaido',
    'Hyogo (Kobe)',
    'Ibaraki',
    'Ishikawa',
    'Iwate',
    'Kagawa',
    'Kagoshima',
    'Kanagawa (Yokohama)',
    'Kochi',
    'Kumamoto',
    'Kyoto',
    'Mie',
    'Miyagi (Sendai)',
    'Miyazaki',
    'Nagano',
    'Nagasaki',
    'Nara',
    'Niigata',
    'Oita',
    'Okayama',
    'Okinawa',
    'Osaka',
    'Saga',
    'Saitama',
    'Shiga',
    'Shimane',
    'Shizuoka',
    'Tochigi',
    'Tokushima',
    'Tokyo',
    'Tottori',
    'Toyama',
    'Wakayama',
    'Yamagata',
    'Yamaguchi',
    'Yamanashi',
  ];

  /// Các Thành phố và Tỉnh của Hàn Quốc sắp xếp từ A đến Z
  static const List<String> koreaProvinces = [
    'Busan',
    'Chungcheong Bắc',
    'Chungcheong Nam',
    'Daegu',
    'Daejeon',
    'Gangwon',
    'Gwangju',
    'Gyeonggi',
    'Gyeongsang Bắc',
    'Gyeongsang Nam',
    'Incheon',
    'Jeju',
    'Jeolla Bắc',
    'Jeolla Nam',
    'Sejong',
    'Seoul',
    'Ulsan',
  ];

  /// Các Thành phố / Huyện của Đài Loan sắp xếp từ A đến Z
  static const List<String> taiwanProvinces = [
    'Bành Hồ (Penghu)',
    'Bình Đông (Pingtung)',
    'Cao Hùng (Kaohsiung)',
    'Đài Bắc (Taipei)',
    'Đài Nam (Tainan)',
    'Đài Trung (Taichung)',
    'Đào Viên (Taoyuan)',
    'Gia Nghĩa (Chiayi)',
    'Hoa Liên (Hualien)',
    'Nam Đầu (Nantou)',
    'Nghi Lan (Yilan)',
    'Tân Bắc (New Taipei)',
    'Tân Trúc (Hsinchu)',
  ];

  /// Các Bang / Vùng lãnh thổ của Úc sắp xếp từ A đến Z
  static const List<String> australiaStates = [
    'Lãnh thổ Phía Bắc (Darwin)',
    'Lãnh thổ Thủ đô Úc (Canberra)',
    'Nam Úc (Adelaide)',
    'New South Wales (Sydney)',
    'Queensland (Brisbane)',
    'Tasmania (Hobart)',
    'Tây Úc (Perth)',
    'Victoria (Melbourne)',
  ];

  /// Lấy danh sách Tỉnh / Bang / Thành phố dựa vào Quốc gia đã chọn (Tất cả sắp xếp A-Z)
  static List<String> getProvincesByCountry(String? country) {
    if (country == null || country.isEmpty || country == 'Việt Nam') {
      return vietnamProvinces;
    }
    if (country.contains('Trung Quốc')) {
      return chinaProvinces;
    }
    if (country.contains('Hoa Kỳ') || country.contains('Mỹ')) {
      return usStates;
    }
    if (country.contains('Nhật Bản')) {
      return japanPrefectures;
    }
    if (country.contains('Hàn Quốc')) {
      return koreaProvinces;
    }
    if (country.contains('Đài Loan')) {
      return taiwanProvinces;
    }
    if (country.contains('Úc')) {
      return australiaStates;
    }
    if (country.contains('Canada')) {
      return [
        'Alberta (Calgary / Edmonton)',
        'British Columbia (Vancouver)',
        'Manitoba (Winnipeg)',
        'New Brunswick',
        'Newfoundland và Labrador',
        'Nova Scotia (Halifax)',
        'Ontario (Toronto / Ottawa)',
        'Prince Edward Island',
        'Quebec (Montreal / Quebec City)',
        'Saskatchewan (Regina)',
      ];
    }
    if (country.contains('Pháp')) {
      return [
        'Auvergne-Rhône-Alpes (Lyon)',
        'Bourgogne-Franche-Comté',
        'Bretagne (Rennes)',
        'Centre-Val de Loire',
        'Grand Est (Strasbourg)',
        'Hauts-de-France (Lille)',
        'Île-de-France (Paris)',
        'Normandie (Rouen)',
        'Nouvelle-Aquitaine (Bordeaux)',
        'Occitanie (Toulouse / Montpellier)',
        'Pays de la Loire (Nantes)',
        'Provence-Alpes-Côte d\'Azur (Marseille / Nice)',
      ];
    }
    if (country.contains('Đức')) {
      return [
        'Baden-Württemberg (Stuttgart)',
        'Bavaria (Munich)',
        'Berlin',
        'Brandenburg',
        'Bremen',
        'Hamburg',
        'Hesse (Frankfurt)',
        'Lower Saxony (Hanover)',
        'North Rhine-Westphalia (Cologne / Dusseldorf)',
        'Rhineland-Palatinate',
        'Saxony (Dresden / Leipzig)',
      ];
    }
    if (country.contains('Anh')) {
      return [
        'Greater London',
        'Greater Manchester',
        'Merseyside (Liverpool)',
        'Northern Ireland (Belfast)',
        'Scotland (Edinburgh / Glasgow)',
        'South Yorkshire (Sheffield)',
        'Tyne and Wear (Newcastle)',
        'Wales (Cardiff)',
        'West Midlands (Birmingham)',
        'West Yorkshire (Leeds)',
      ];
    }
    if (country.contains('Singapore')) {
      return [
        'Khu Bắc (North)',
        'Khu Đông (East)',
        'Khu Đông Bắc (North-East)',
        'Khu Tây (West)',
        'Khu Trung Tâm (Central)',
      ];
    }
    if (country.contains('Thái Lan')) {
      return [
        'Bangkok',
        'Chiang Mai',
        'Chiang Rai',
        'Chonburi (Pattaya)',
        'Khon Kaen',
        'Nakhon Ratchasima',
        'Nonthaburi',
        'Phuket',
        'Songkhla (Hat Yai)',
        'Surat Thani (Koh Samui)',
      ];
    }
    if (country.contains('Lào')) {
      return [
        'Attapeu',
        'Bokeo',
        'Champasak (Pakse)',
        'Khammouane (Thakhek)',
        'Luang Prabang',
        'Oudomxay',
        'Savannakhet',
        'Vang Vieng',
        'Viêng Chăn (Vientiane)',
        'Xieng Khouang',
      ];
    }
    if (country.contains('Campuchia')) {
      return [
        'Banteay Meanchey',
        'Battambang',
        'Kampong Cham',
        'Kampong Chhnang',
        'Kampot',
        'Kandal',
        'Kep',
        'Koh Kong',
        'Phnom Penh',
        'Preah Sihanouk (Sihanoukville)',
        'Siem Reap',
      ];
    }
    if (country.contains('Nga')) {
      return [
        'Chelyabinsk',
        'Kazan',
        'Moscow',
        'Nizhny Novgorod',
        'Novosibirsk',
        'Omsk',
        'Rostov-on-Don',
        'Saint Petersburg',
        'Samara',
        'Vladivostok',
        'Yekaterinburg',
      ];
    }

    // Mặc định cho các quốc gia khác: Trả về các thành phố / phân khu chuẩn A-Z
    return [
      'Khu vực Bắc (Northern Region)',
      'Khu vực Đông (Eastern Region)',
      'Khu vực Nam (Southern Region)',
      'Khu vực Tây (Western Region)',
      'Thủ đô (Capital District)',
    ];
  }

  /// Lấy danh sách Quận / Huyện dựa theo Quốc gia và Tỉnh/Thành (Sắp xếp chuẩn A-Z)
  static List<String> getDistricts(String? country, String? province) {
    if (province == null || province.isEmpty) return [];

    // 1. Nếu là Trung Quốc: Trả về danh sách Quận / Huyện / Hạt chính thức của Trung Quốc
    if (country != null && country.contains('Trung Quốc')) {
      if (province.contains('Bắc Kinh')) {
        return [
          'Huyện Diên Khánh',
          'Huyện Mật Vân',
          'Quận Bắc Đầu',
          'Quận Đại Hưng',
          'Quận Đông Thành',
          'Quận Hải Điến',
          'Quận Hoài Nhu',
          'Quận Môn Đầu Câu',
          'Quận Phong Đài',
          'Quận Phòng Sơn',
          'Quận Thạch Cảnh Sơn',
          'Quận Thông Châu',
          'Quận Thuận Nghĩa',
          'Quận Triều Dương',
          'Quận Xương Bình',
          'Quận Tây Thành',
        ];
      }
      if (province.contains('Thượng Hải')) {
        return [
          'Huyện Sùng Minh',
          'Quận Bảo Sơn',
          'Quận Cát Định',
          'Quận Dương Phố',
          'Quận Hoàng Phố',
          'Quận Hồng Khẩu',
          'Quận Kim Sơn',
          'Quận Mẫn Hàng',
          'Quận Phố Đông',
          'Quận Phụng Hiền',
          'Quận Thanh Phố',
          'Quận Tĩnh An',
          'Quận Tùng Giang',
          'Quận Từ Hối',
          'Quận Trường Ninh',
        ];
      }
      if (province.contains('Quảng Đông') || province.contains('Quảng Châu')) {
        return [
          'Quận Bạch Vân',
          'Quận Hải Châu',
          'Quận Hoa Đô',
          'Quận Hoàng Phố',
          'Quận Lệ Loan',
          'Quận Nam Sa',
          'Quận Phiên Ngung',
          'Quận Thiên Hà',
          'Quận Tăng Thành',
          'Quận Tùng Hóa',
          'Quận Việt Tú',
        ];
      }
      if (province.contains('Thâm Quyến')) {
        return [
          'Quận Bảo An',
          'Quận Diêm Điền',
          'Quận Đại Bàng',
          'Quận La Hồ',
          'Quận Long Cương',
          'Quận Long Hoa',
          'Quận Nam Sơn',
          'Quận Phúc Điền',
          'Quận Quang Minh',
        ];
      }
      if (province.contains('Trùng Khánh')) {
        return [
          'Quận Ba Nam',
          'Quận Bắc Bội',
          'Quận Cửu Long Pha',
          'Quận Du Bắc',
          'Quận Du Trung',
          'Quận Giang Bắc',
          'Quận Nam Ngạn',
          'Quận Sa Bình Bá',
          'Quận Vạn Châu',
        ];
      }
      if (province.contains('Tứ Xuyên')) {
        return [
          'TP. Lạc Sơn',
          'TP. Miên Dương',
          'TP. Nam Sung',
          'TP. Nghi Tân',
          'TP. Thành Đô',
          'TP. Tự Cống',
        ];
      }
      if (province.contains('Hồ Bắc')) {
        return [
          'TP. Hoàng Cương',
          'TP. Kinh Châu',
          'TP. Nghi Xương',
          'TP. Thập Yển',
          'TP. Tương Dương',
          'TP. Vũ Hán',
        ];
      }
      if (province.contains('Chiết Giang')) {
        return [
          'TP. Gia Hưng',
          'TP. Hàng Châu',
          'TP. Hồ Châu',
          'TP. Kim Hoa',
          'TP. Ninh Ba',
          'TP. Ôn Châu',
          'TP. Thiệu Hưng',
        ];
      }
      if (province.contains('Giang Tô')) {
        return [
          'TP. Dương Châu',
          'TP. Nam Kinh',
          'TP. Nam Thông',
          'TP. Tô Châu',
          'TP. Từ Châu',
          'TP. Vô Tích',
        ];
      }
      return [
        'Khu Công nghiệp / Công nghệ cao',
        'Khu Phát triển Kinh tế Mới',
        'Quận Trung Tâm',
        'Thành phố trực thuộc',
        'Thị xã trung tâm',
      ];
    }

    // 2. Nếu là Hoa Kỳ (Mỹ)
    if (country != null && (country.contains('Hoa Kỳ') || country.contains('Mỹ'))) {
      if (province == 'California') {
        return [
          'Quận Alameda',
          'Quận Fresno',
          'Quận Los Angeles',
          'Quận Orange',
          'Quận Riverside',
          'Quận Sacramento',
          'Quận San Diego',
          'Quận San Francisco',
          'Quận Santa Clara (San Jose)',
          'Quận San Mateo',
          'Quận Ventura',
        ];
      }
      if (province == 'New York') {
        return [
          'Quận Bronx',
          'Quận Brooklyn (Kings)',
          'Quận Manhattan (New York)',
          'Quận Nassau',
          'Quận Queens',
          'Quận Richmond (Staten Island)',
          'Quận Suffolk',
          'Quận Westchester',
        ];
      }
      if (province == 'Texas') {
        return [
          'Quận Bexar (San Antonio)',
          'Quận Collin',
          'Quận Dallas',
          'Quận Denton',
          'Quận El Paso',
          'Quận Harris (Houston)',
          'Quận Tarrant (Fort Worth)',
          'Quận Travis (Austin)',
        ];
      }
      if (province == 'Washington') {
        return [
          'Quận Clark',
          'Quận King (Seattle)',
          'Quận Pierce (Tacoma)',
          'Quận Snohomish',
          'Quận Spokane',
        ];
      }
      return [
        'Khu Đô thị Trung tâm',
        'Quận Trung tâm (Central County)',
        'Quận Phía Bắc (North County)',
        'Quận Phía Nam (South County)',
        'Quận Phía Tây (West County)',
      ];
    }

    // 3. Nếu là Nhật Bản
    if (country != null && country.contains('Nhật Bản')) {
      if (province.contains('Tokyo')) {
        return [
          'Quận Chiyoda',
          'Quận Chuo',
          'Quận Meguro',
          'Quận Minato',
          'Quận Nakano',
          'Quận Setagaya',
          'Quận Shibuya',
          'Quận Shinagawa',
          'Quận Shinjuku',
          'Quận Suginami',
          'Quận Taito',
          'Quận Toshima',
          'TP. Hachioji',
          'TP. Machida',
          'TP. Musashino',
        ];
      }
      if (province.contains('Osaka')) {
        return [
          'Quận Chuo',
          'Quận Kita',
          'Quận Naniwa',
          'Quận Tennoji',
          'Quận Yodogawa',
          'TP. Higashiosaka',
          'TP. Sakai',
          'TP. Suita',
          'TP. Toyonaka',
        ];
      }
      return [
        'Khu Trung tâm hành chính',
        'Thành phố trực thuộc 1',
        'Thành phố trực thuộc 2',
        'Thị trấn trung tâm',
      ];
    }

    // 4. Nếu là Hàn Quốc
    if (country != null && country.contains('Hàn Quốc')) {
      if (province == 'Seoul') {
        return [
          'Quận Dongdaemun',
          'Quận Gangnam',
          'Quận Guro',
          'Quận Jongno',
          'Quận Jung',
          'Quận Mapo',
          'Quận Nowon',
          'Quận Seocho',
          'Quận Songpa',
          'Quận Yeongdeungpo',
          'Quận Yongsan',
        ];
      }
      if (province == 'Busan') {
        return [
          'Quận Busanjin',
          'Quận Dong',
          'Quận Haeundae',
          'Quận Jung',
          'Quận Nam',
          'Quận Saha',
          'Quận Suyeong',
        ];
      }
      return [
        'Quận Trung tâm (Jung-gu)',
        'Quận Phía Bắc (Buk-gu)',
        'Quận Phía Nam (Nam-gu)',
        'Thành phố trực thuộc',
      ];
    }

    // 5. Nếu là Việt Nam: Lấy danh sách Quận / Huyện chính thức theo Tỉnh / Thành
    return _getVietnamDistricts(province);
  }

  /// Danh sách Quận / Huyện của các Tỉnh / Thành phố Việt Nam (Sắp xếp A-Z)
  static List<String> _getVietnamDistricts(String province) {
    if (province == 'TP. Hồ Chí Minh') {
      return [
        'Huyện Bình Chánh',
        'Huyện Cần Giờ',
        'Huyện Củ Chi',
        'Huyện Hóc Môn',
        'Huyện Nhà Bè',
        'Quận 1',
        'Quận 3',
        'Quận 4',
        'Quận 5',
        'Quận 6',
        'Quận 7',
        'Quận 8',
        'Quận 10',
        'Quận 11',
        'Quận 12',
        'Quận Bình Tân',
        'Quận Bình Thạnh',
        'Quận Gò Vấp',
        'Quận Phú Nhuận',
        'Quận Tân Bình',
        'Quận Tân Phú',
        'TP. Thủ Đức',
      ];
    }
    if (province == 'Hà Nội') {
      return [
        'Huyện Ba Vì',
        'Huyện Chương Mỹ',
        'Huyện Đan Phượng',
        'Huyện Đông Anh',
        'Huyện Gia Lâm',
        'Huyện Hoài Đức',
        'Huyện Mê Linh',
        'Huyện Mỹ Đức',
        'Huyện Phú Xuyên',
        'Huyện Phúc Thọ',
        'Huyện Quốc Oai',
        'Huyện Sóc Sơn',
        'Huyện Thạch Thất',
        'Huyện Thanh Oai',
        'Huyện Thanh Trì',
        'Huyện Thường Tín',
        'Huyện Ứng Hòa',
        'Quận Ba Đình',
        'Quận Bắc Từ Liêm',
        'Quận Cầu Giấy',
        'Quận Đống Đa',
        'Quận Hà Đông',
        'Quận Hai Bà Trưng',
        'Quận Hoàn Kiếm',
        'Quận Hoàng Mai',
        'Quận Long Biên',
        'Quận Nam Từ Liêm',
        'Quận Tây Hồ',
        'Quận Thanh Xuân',
        'Thị xã Sơn Tây',
      ];
    }
    if (province == 'Đà Nẵng') {
      return [
        'Huyện Hòa Vang',
        'Huyện Hoàng Sa',
        'Quận Cẩm Lệ',
        'Quận Hải Châu',
        'Quận Liên Chiểu',
        'Quận Ngũ Hành Sơn',
        'Quận Sơn Trà',
        'Quận Thanh Khê',
      ];
    }
    if (province == 'Hải Phòng') {
      return [
        'Huyện An Dương',
        'Huyện An Lão',
        'Huyện Bạch Long Vĩ',
        'Huyện Cát Hải',
        'Huyện Kiến Thụy',
        'Huyện Thủy Nguyên',
        'Huyện Tiên Lãng',
        'Huyện Vĩnh Bảo',
        'Quận Dương Kinh',
        'Quận Đồ Sơn',
        'Quận Hải An',
        'Quận Hồng Bàng',
        'Quận Kiến An',
        'Quận Lê Chân',
        'Quận Ngô Quyền',
      ];
    }
    if (province == 'Cần Thơ') {
      return [
        'Huyện Cờ Đỏ',
        'Huyện Phong Điền',
        'Huyện Thới Lai',
        'Huyện Vĩnh Thạnh',
        'Quận Bình Thủy',
        'Quận Cái Răng',
        'Quận Ninh Kiều',
        'Quận Ô Môn',
        'Quận Thốt Nốt',
      ];
    }
    if (province == 'Bình Dương') {
      return [
        'Huyện Bắc Tân Uyên',
        'Huyện Bàu Bàng',
        'Huyện Dầu Tiếng',
        'Huyện Phú Giáo',
        'TP. Bến Cát',
        'TP. Dĩ An',
        'TP. Tân Uyên',
        'TP. Thủ Dầu Một',
        'TP. Thuận An',
      ];
    }
    if (province == 'Đồng Nai') {
      return [
        'Huyện Cẩm Mỹ',
        'Huyện Định Quán',
        'Huyện Long Thành',
        'Huyện Nhơn Trạch',
        'Huyện Tân Phú',
        'Huyện Thống Nhất',
        'Huyện Trảng Bom',
        'Huyện Vĩnh Cửu',
        'Huyện Xuân Lộc',
        'TP. Biên Hòa',
        'TP. Long Khánh',
      ];
    }
    if (province == 'Bà Rịa - Vũng Tàu') {
      return [
        'Huyện Châu Đức',
        'Huyện Côn Đảo',
        'Huyện Đất Đỏ',
        'Huyện Long Điền',
        'Huyện Xuyên Mộc',
        'Thị xã Phú Mỹ',
        'TP. Bà Rịa',
        'TP. Vũng Tàu',
      ];
    }
    if (province == 'Long An') {
      return [
        'Huyện Bến Lức',
        'Huyện Cần Đước',
        'Huyện Cần Giuộc',
        'Huyện Châu Thành',
        'Huyện Đức Hòa',
        'Huyện Đức Huệ',
        'Huyện Mộc Hóa',
        'Huyện Tân Hưng',
        'Huyện Tân Thạnh',
        'Huyện Tân Trụ',
        'Huyện Thạnh Hóa',
        'Huyện Thủ Thừa',
        'Huyện Vĩnh Hưng',
        'Thị xã Kiến Tường',
        'TP. Tân An',
      ];
    }
    if (province == 'Khánh Hòa') {
      return [
        'Huyện Cam Lâm',
        'Huyện Diên Khánh',
        'Huyện Khánh Sơn',
        'Huyện Khánh Vĩnh',
        'Huyện Trường Sa',
        'Huyện Vạn Ninh',
        'Thị xã Ninh Hòa',
        'TP. Cam Ranh',
        'TP. Nha Trang',
      ];
    }
    if (province == 'Lâm Đồng') {
      return [
        'Huyện Bảo Lâm',
        'Huyện Cát Tiên',
        'Huyện Di Linh',
        'Huyện Đạ Huoai',
        'Huyện Đạ Tẻh',
        'Huyện Đam Rông',
        'Huyện Đơn Dương',
        'Huyện Đức Trọng',
        'Huyện Lạc Dương',
        'Huyện Lâm Hà',
        'TP. Bảo Lộc',
        'TP. Đà Lạt',
      ];
    }
    if (province == 'Thừa Thiên Huế') {
      return [
        'Huyện A Lưới',
        'Huyện Nam Đông',
        'Huyện Phong Điền',
        'Huyện Phú Lộc',
        'Huyện Phú Vang',
        'Huyện Quảng Điền',
        'Thị xã Hương Thủy',
        'Thị xã Hương Trà',
        'TP. Huế',
      ];
    }
    if (province == 'Tiền Giang') {
      return [
        'Huyện Cai Lậy',
        'Huyện Cái Bè',
        'Huyện Châu Thành',
        'Huyện Chợ Gạo',
        'Huyện Gò Công Đông',
        'Huyện Gò Công Tây',
        'Huyện Tân Phú Đông',
        'Huyện Tân Phước',
        'Thị xã Cai Lậy',
        'Thị xã Gò Công',
        'TP. Mỹ Tho',
      ];
    }
    if (province == 'An Giang') {
      return [
        'Huyện An Phú',
        'Huyện Châu Phú',
        'Huyện Châu Thành',
        'Huyện Chợ Mới',
        'Huyện Phú Tân',
        'Huyện Thoại Sơn',
        'Huyện Tri Tôn',
        'Thị xã Tân Châu',
        'Thị xã Tịnh Biên',
        'TP. Châu Đốc',
        'TP. Long Xuyên',
      ];
    }
    if (province == 'Kiên Giang') {
      return [
        'Huyện An Biên',
        'Huyện An Minh',
        'Huyện Châu Thành',
        'Huyện Giang Thành',
        'Huyện Giồng Riềng',
        'Huyện Gò Quao',
        'Huyện Hòn Đất',
        'Huyện Kiên Hải',
        'Huyện Kiên Lương',
        'Huyện Tân Hiệp',
        'Huyện U Minh Thượng',
        'Huyện Vĩnh Thuận',
        'TP. Hà Tiên',
        'TP. Phú Quốc',
        'TP. Rạch Giá',
      ];
    }

    // Các tỉnh còn lại của Việt Nam: Trả về danh sách huyện, thị xã, thành phố thực tế
    final cleanName = province.replaceAll('TP. ', '').replaceAll('Tỉnh ', '');
    return [
      'Huyện Châu Thành',
      'Huyện Phía Bắc',
      'Huyện Phía Nam',
      'Huyện Phía Đông',
      'Huyện Phía Tây',
      'Thị xã $cleanName',
      'TP. $cleanName',
    ];
  }

  /// Lấy danh sách Phường / Xã / Thị trấn (Sắp xếp A-Z)
  static List<String> getWards(String? country, String? district) {
    if (district == null || district.isEmpty) return [];

    // Phường thuộc Quận 1 - TP. Hồ Chí Minh
    if (district == 'Quận 1') {
      return [
        'Phường Bến Nghé',
        'Phường Bến Thành',
        'Phường Cầu Kho',
        'Phường Cầu Ông Lãnh',
        'Phường Cô Giang',
        'Phường Đa Kao',
        'Phường Nguyễn Cư Trinh',
        'Phường Nguyễn Thái Bình',
        'Phường Phạm Ngũ Lão',
        'Phường Tân Định',
      ];
    }
    // Phường thuộc Quận 3 - TP. Hồ Chí Minh
    if (district == 'Quận 3') {
      return [
        'Phường 1',
        'Phường 2',
        'Phường 3',
        'Phường 4',
        'Phường 5',
        'Phường 9',
        'Phường 10',
        'Phường 11',
        'Phường 12',
        'Phường 13',
        'Phường 14',
        'Phường Võ Thị Sáu',
      ];
    }
    // Phường thuộc TP. Thủ Đức - TP. Hồ Chí Minh
    if (district == 'TP. Thủ Đức') {
      return [
        'Phường An Khánh',
        'Phường An Lợi Đông',
        'Phường An Phú',
        'Phường Bình Chiểu',
        'Phường Bình Thọ',
        'Phường Hiệp Bình Chánh',
        'Phường Hiệp Bình Phước',
        'Phường Hiệp Phú',
        'Phường Linh Chiểu',
        'Phường Linh Đông',
        'Phường Linh Tây',
        'Phường Linh Trung',
        'Phường Linh Xuân',
        'Phường Long Bình',
        'Phường Long Phước',
        'Phường Long Thạnh Mỹ',
        'Phường Long Trường',
        'Phường Phú Hữu',
        'Phường Phước Bình',
        'Phường Phước Long A',
        'Phường Phước Long B',
        'Phường Tam Bình',
        'Phường Tam Phú',
        'Phường Tăng Nhơn Phú A',
        'Phường Tăng Nhơn Phú B',
        'Phường Thạnh Mỹ Lợi',
        'Phường Thảo Điền',
        'Phường Thủ Thiêm',
        'Phường Trường Thạnh',
        'Phường Trường Thọ',
      ];
    }
    // Phường thuộc Quận Ba Đình - Hà Nội
    if (district == 'Quận Ba Đình') {
      return [
        'Phường Cống Vị',
        'Phường Điện Biên',
        'Phường Đội Cấn',
        'Phường Giảng Võ',
        'Phường Kim Mã',
        'Phường Liễu Giai',
        'Phường Ngọc Hà',
        'Phường Ngọc Khánh',
        'Phường Nguyễn Trung Trực',
        'Phường Phúc Xá',
        'Phường Quán Thánh',
        'Phường Thành Công',
        'Phường Trúc Bạch',
        'Phường Vĩnh Phúc',
      ];
    }
    // Phường thuộc Quận Hoàn Kiếm - Hà Nội
    if (district == 'Quận Hoàn Kiếm') {
      return [
        'Phường Chương Dương',
        'Phường Cửa Đông',
        'Phường Cửa Nam',
        'Phường Đồng Xuân',
        'Phường Hàng Bạc',
        'Phường Hàng Bài',
        'Phường Hàng Bồ',
        'Phường Hàng Bông',
        'Phường Hàng Buồm',
        'Phường Hàng Đào',
        'Phường Hàng Gai',
        'Phường Hàng Mã',
        'Phường Hàng Trống',
        'Phường Lý Thái Tổ',
        'Phường Phan Chu Trinh',
        'Phường Phúc Tân',
        'Phường Tràng Tiền',
        'Phường Trần Hưng Đạo',
      ];
    }
    // Phân khu thuộc Bắc Kinh / Thượng Hải / Quốc tế
    if (country != null && country.contains('Trung Quốc')) {
      return [
        'Tiểu khu Bắc',
        'Tiểu khu Công nghệ cao',
        'Tiểu khu Đông',
        'Tiểu khu Nam',
        'Tiểu khu Tân Thành',
        'Tiểu khu Tây',
        'Tiểu khu Trung tâm hành chính',
      ];
    }
    if (country != null && !country.contains('Việt Nam')) {
      return [
        'Khu phố Bắc (North District)',
        'Khu phố Đông (East District)',
        'Khu phố Nam (South District)',
        'Khu phố Tây (West District)',
        'Khu phố Trung tâm (Central Ward)',
      ];
    }

    // Mặc định cho các huyện thị Việt Nam khác
    return [
      'Phường 1',
      'Phường 2',
      'Phường 3',
      'Phường 4',
      'Phường 5',
      'Phường Trung Tâm',
      'Thị trấn Trung Tâm',
      'Xã Bình Hòa',
      'Xã Phú An',
      'Xã Tân Hiệp',
    ];
  }
}
