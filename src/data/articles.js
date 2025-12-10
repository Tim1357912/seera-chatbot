// src/data/articles.js

const fullArticlesData = [
  // ARTIKEL 1 (Contoh Lengkap)
  {
    id: 1,
    title: '10 Cara Mix & Match Gamis untuk Berbagai Acara',
    category: 'Fashion Tips',
    author: 'Siti Nurhaliza',
    date: '3 Desember 2025',
    readTime: 8,
    image: '/gamis.png',
    lead: 'Gamis adalah salah satu pakaian modest yang paling serbaguna. Dengan styling yang tepat, satu gamis bisa digunakan untuk berbagai acara, dari casual hangout hingga acara formal. Mari kita pelajari cara mix and match gamis agar tampilan Anda selalu fresh dan stylish.',
    
    content: [
      {
        heading: '1. Gamis untuk Acara Casual',
        paragraphs: [
          'Untuk tampilan sehari-hari yang santai namun tetap modest, pilih gamis dengan bahan yang ringan dan breathable seperti katun atau linen. Kombinasikan dengan outer seperti cardigan atau kimono untuk sentuhan lebih trendy.',
          'Aksesoris minimal seperti tas selempang kecil dan sneakers putih akan membuat penampilan Anda terlihat effortless namun tetap stylish. Jangan lupa pilih warna-warna netral yang mudah dipadukan.'
        ],
        image: '/gamis.png',
        imageCaption: 'Contoh styling gamis untuk acara casual dengan outer dan sneakers'
      },
      {
        heading: '2. Gamis untuk Hangout Bersama Teman',
        paragraphs: [
          'Saat hangout dengan teman, Anda bisa lebih berani bereksperimen dengan warna dan motif. Gamis dengan warna pastel atau motif floral akan memberikan kesan ceria dan menyenangkan.',
          'Tambahkan aksesoris statement seperti kalung chunky atau anting-anting besar untuk menonjolkan kepribadian Anda. Belt di pinggang juga bisa membuat siluet lebih defined.'
        ],
        tips: [
          { title: 'Warna', description: 'Pilih warna-warna cerah seperti mint, lavender, atau soft pink' },
          { title: 'Aksesoris', description: 'Gunakan statement pieces untuk focal point' },
          { title: 'Footwear', description: 'Sandal platform atau wedges untuk extra height' }
        ]
      },
      {
        heading: '3. Gamis untuk Acara Formal',
        paragraphs: [
          'Untuk acara formal seperti pernikahan atau gathering kantor, pilih gamis dengan bahan yang lebih premium seperti satin, velvet, atau silk. Warna-warna gelap seperti navy, maroon, atau emerald green akan memberikan kesan elegan.',
          'Detail seperti payet, bordir, atau cutting yang unik akan membuat tampilan Anda lebih mewah. Pastikan gamis tidak terlalu ketat dan tetap nyaman untuk dikenakan seharian.'
        ]
      },
      {
        heading: '4. Layer dengan Outer yang Tepat',
        paragraphs: [
          'Outer adalah kunci untuk mengubah tampilan gamis. Blazer memberikan kesan profesional, kimono memberikan kesan bohemian, sementara cardigan panjang memberikan kesan casual chic.',
          'Pilih outer dengan warna yang kontras atau komplementer dengan gamis Anda. Misalnya, gamis putih dengan blazer hitam, atau gamis navy dengan cardigan mustard.'
        ],
        image: '/koko.png',
        imageCaption: 'Berbagai pilihan outer untuk styling gamis'
      },
      {
        heading: '10. Percaya Diri adalah Kunci',
        paragraphs: [
          'Yang paling penting dalam styling adalah rasa percaya diri. Kenakan apa yang membuat Anda merasa nyaman dan confident. Fashion adalah tentang expressing yourself, bukan mengikuti trend membabi buta.',
          'Eksperimen dengan berbagai style, temukan apa yang cocok untuk Anda, dan jangan takut untuk keluar dari zona nyaman. Remember, modest fashion doesn\'t mean boring fashion!'
        ]
      }
    ],
    conclusion: 'Gamis adalah investasi fashion yang sangat versatile. Dengan tips mix and match di atas, satu gamis bisa Anda styling untuk berbagai acara berbeda. Kuncinya adalah kreativitas dalam memadukan outer, aksesoris, dan footwear yang tepat. Selamat bereksperimen dan temukan style Anda sendiri!',
    tags: ['gamis', 'styling', 'modest fashion', 'fashion tips', 'mix and match', 'outfit ideas']
  },
  
  // ARTIKEL 2
  { 
    id: 2, 
    title: 'Tren Warna Hijab Favorit di 2025', 
    category: 'Trend 2025', 
    author: 'Ani Fadillah', 
    date: '2 Des 2025', 
    readTime: 5, 
    image: '/koko.png', 
    lead: 'Warna-warna earth tone masih mendominasi panggung fashion 2025, namun sentuhan warna-warna cerah yang berani mulai muncul sebagai statement. Kami merangkum warna hijab yang wajib Anda miliki tahun ini!', 
    content: [
      { 
        heading: '1. Kehangatan Earth Tone (Sage & Terracotta)', 
        paragraphs: [
          'Warna Sage Green dan Terracotta tetap menjadi primadona karena kemampuannya memberikan kesan elegan dan mudah dipadukan dengan berbagai warna busana. Pilih hijab dengan material satin atau silk untuk acara formal.'
        ], 
        image: '/sage-hijab.png', 
        imageCaption: 'Kombinasi Sage Green dan Terracotta.'
      },
      { 
        heading: '2. Statement Color: Royal Blue', 
        paragraphs: [
          'Royal Blue kembali populer. Warna biru tua yang kaya ini cocok untuk kulit sawo matang dan mampu memberikan kesan powerful dan percaya diri.'
        ], 
        tips: [
          { title: 'Acara', description: 'Sempurna untuk acara malam atau formal' },
          { title: 'Paduan Warna', description: 'Padukan dengan busana krem atau abu-abu muda' }
        ]
      },
      {
        heading: '3. Pastel Lembut (Lilac Mist)', 
        paragraphs: [
          'Lilac Mist adalah versi pastel dari ungu yang lebih lembut dan feminin. Warna ini memberikan aura muda dan manis, ideal untuk digunakan saat siang hari atau acara santai.'
        ]
      }
    ], 
    conclusion: 'Dominasi earth tone dan warna klasik menunjukkan kematangan dalam tren modest wear. Kuncinya adalah memilih shade yang sesuai dengan warna kulit dan jenis acara Anda.', 
    tags: ['hijab', 'trend', 'warna 2025', 'modest fashion', 'earth tone'] 
  },

  // ARTIKEL 3
  { 
    id: 3, 
    title: 'Panduan Memilih Koko Modern untuk Pria', 
    category: 'Styling Guide', 
    author: 'Budi Santoso', 
    date: '1 Des 2025', 
    readTime: 7, 
    image: '/koko-hijau.png', 
    lead: 'Kemeja koko modern menawarkan perpaduan sempurna antara tradisi dan gaya kontemporer, membuatnya nyaman dipakai untuk ibadah maupun acara kasual. Berikut panduan lengkap memilih koko yang tepat.', 
    content: [
      { 
        heading: '1. Material: Kenyamanan di Iklim Tropis', 
        paragraphs: [
          'Untuk iklim tropis, pilihlah bahan **Katun** atau **Linen** yang menyerap keringat. Untuk tampilan lebih formal, bahan **Dobby** atau **Twill** bisa menjadi pilihan yang elegan.'
        ], 
        image: '/koko-bahan.png', 
        imageCaption: 'Pilih bahan katun premium.'
      },
      { 
        heading: '2. Cutting: Antara Slim-fit dan Regular-fit', 
        paragraphs: [
          'Koko modern seringkali hadir dengan potongan **Slim-fit** yang lebih mengikuti bentuk tubuh tanpa terasa ketat. Potongan kerah Shanghai memberikan kesan clean dan minimalis.'
        ], 
        tips: [
          { title: 'Formal', description: 'Putih bersih atau warna gelap solid' },
          { title: 'Casual', description: 'Warna-warna pastel atau earth tone' }
        ]
      },
      { 
        heading: '3. Warna dan Detail Minimalis', 
        paragraphs: [
          'Selain putih, koko modern kini hadir dalam warna-warna maskulin seperti **Navy, Maroon, Olive Green, atau Grey**. Cari detail sulaman geometris sederhana, hindari sulaman yang terlalu ramai.'
        ]
      }
    ], 
    conclusion: 'Koko modern adalah evolusi dari busana muslim pria. Dengan memilih bahan yang tepat dan memperhatikan cutting, Anda bisa tampil stylish, rapi, dan tetap sopan dalam berbagai kesempatan.', 
    tags: ['koko', 'pria', 'styling guide', 'fashion pria', 'busana muslim'] 
  },

  // ARTIKEL 4
  { 
    id: 4, 
    title: 'Review: Koleksi Abaya Premium Seera', 
    category: 'Product Review', 
    author: 'Siti Nurhaliza', 
    date: '30 Nov 2025', 
    readTime: 6, 
    image: '/gamis.png', 
    lead: 'Koleksi Abaya Premium dari Seera hadir dengan janji kualitas bahan dan desain eksklusif. Kami mengulas secara detail mulai dari jahitan, material, hingga fitur-fitur yang membuat abaya ini layak menjadi investasi fashion Anda.', 
    content: [
      { 
        heading: '1. Kualitas Material yang Tak Tertandingi', 
        paragraphs: [
          'Abaya Seera umumnya menggunakan material **Lexury Jet Black** atau **Nidha** yang terkenal sangat ringan, jatuh (drape) sempurna, dan memiliki warna hitam pekat yang tidak mudah pudar.'
        ], 
        tips: [
          { title: 'Material', description: 'Dibuat dari kain Nidha/Jet Black kelas atas' },
          { title: 'Perawatan', description: 'Disarankan cuci kering (dry clean)' }
        ]
      },
      { 
        heading: '2. Desain dan Finishing Premium', 
        paragraphs: [
          'Fokus Seera pada desain **minimalis elegan** sangat terlihat. Detail kristal atau bordir ditempatkan secara strategis pada manset dan kerah. Jahitan sangat rapi dan kuat.'
        ], 
        image: '/abaya-seera-detail.png', 
        imageCaption: 'Detail minimalis kristal pada manset Abaya Seera.'
      },
      { 
        heading: '3. Fitur Fungsional', 
        paragraphs: [
          'Fitur penting seperti **saku tersembunyi** dan manset dengan **zipper wudhu-friendly** membuat abaya ini praktis bagi wanita yang aktif.'
        ]
      }
    ], 
    conclusion: 'Koleksi Abaya Premium Seera berhasil memenuhi ekspektasi produk premium. Kualitas material, jahitan, dan desain yang fungsional menjadikannya pilihan tepat bagi Anda.', 
    tags: ['abaya', 'review', 'seera', 'premium', 'modest fashion'] 
  },
  
  // ARTIKEL 5 (DISINKRONKAN)
  { 
    id: 5, 
    title: 'Behind The Scene: Proses Produksi Gamis', 
    category: 'Behind The Scene', 
    author: 'Rahmawati', 
    date: '29 November 2024', // Sinkron dengan list '29 Nov 2024'
    readTime: 4, 
    image: '/koko.png', // Sinkron dengan list
    lead: 'Intip proses di balik pembuatan gamis berkualitas, dari pemilihan bahan mentah hingga tahap finishing dan quality control yang ketat. Transparansi proses produksi menjamin kualitas produk akhir.', 
    content: [
      { 
        heading: '1. Pemilihan Material Dasar', 
        paragraphs: [
          'Proses dimulai dengan pemilihan kain premium seperti katun rayon, silk, atau linen. Kami bekerja dengan supplier terpercaya untuk memastikan bahan bebas cacat dan memenuhi standar keberlanjutan.'
        ]
      },
      { 
        heading: '2. Cutting dan Pola Presisi', 
        paragraphs: [
          'Menggunakan teknologi cutting laser dan pola yang dirancang oleh desainer berpengalaman. Presisi dalam pemotongan memastikan setiap gamis memiliki jatuhan (drape) yang sempurna.'
        ], 
        tips: [
          { title: 'Teknologi', description: 'Cutting laser untuk presisi tinggi' },
          { title: 'Pola', description: 'Dirancang untuk kenyamanan modest wear' }
        ]
      },
      { 
        heading: '3. Jahitan dan Finishing', 
        paragraphs: [
          'Setiap gamis dijahit oleh penjahit ahli. Setelah dijahit, produk melewati proses *quality control* (QC) ketat untuk memeriksa jahitan, kancing, zipper, dan detail bordir sebelum dikemas.'
        ],
        image: '/jahit-detail.png', // Asumsi ada gambar ini
        imageCaption: 'Tahap jahitan yang dilakukan oleh tim profesional.'
      }
    ], 
    conclusion: 'Setiap helai gamis Seera adalah hasil dari proses yang teliti, mengutamakan kualitas, kenyamanan, dan keindahan detail.', 
    tags: ['produksi', 'behind the scene', 'gamis', 'quality control'] 
  },

  // ARTIKEL 6 (DISINKRONKAN)
  { 
    id: 6, 
    title: 'Tips Merawat Pakaian Muslim Agar Awet', 
    category: 'Fashion Tips', // Sinkron dengan list
    author: 'Siti Nurhaliza', 
    date: '28 November 2024', // Sinkron dengan list '28 Nov 2024'
    readTime: 6, 
    image: '/koko-hijau.png', // Sinkron dengan list
    lead: 'Cara mencuci, menyimpan, dan merawat gamis, koko, dan abaya agar tetap terlihat seperti baru dan warnanya tidak pudar. Perawatan yang tepat adalah kunci investasi fashion jangka panjang.', 
    content: [
      { 
        heading: '1. Perhatikan Label Perawatan', 
        paragraphs: [
          'Selalu baca label. Umumnya, pakaian modest berbahan premium (satin, brokat, silk) membutuhkan cuci tangan atau *dry clean*. Hindari pemutih yang keras.'
        ]
      },
      { 
        heading: '2. Teknik Mencuci yang Benar', 
        paragraphs: [
          'Gunakan air dingin dan deterjen yang lembut. Jika menggunakan mesin cuci, balik pakaian ke dalam (inside-out) untuk melindungi warna dan detail, serta gunakan siklus putar rendah.'
        ],
        tips: [
          { title: 'Cuci Tangan', description: 'Wajib untuk bahan brokat dan silk' },
          { title: 'Mesin Cuci', description: 'Gunakan *laundry bag* dan air dingin' }
        ]
      },
      { 
        heading: '3. Cara Mengeringkan dan Menyimpan', 
        paragraphs: [
          'Jemur gantung di tempat teduh (hindari sinar matahari langsung). Simpan gamis atau abaya dengan cara digantung menggunakan *hanger* yang empuk untuk menjaga bentuk bahu.'
        ],
        image: '/merawat-koko.png',
        imageCaption: 'Gantung pakaian muslim untuk menjaga bentuk dan menghindari kusut.'
      }
    ], 
    conclusion: 'Perawatan yang cermat akan memperpanjang usia pakai pakaian muslim premium Anda, menjadikannya investasi yang berharga.', 
    tags: ['perawatan', 'laundry', 'gamis', 'koko', 'tips awet'] 
  },

  // ARTIKEL 7 (DISINKRONKAN)
  { 
    id: 7, 
    title: 'Aksesoris Pelengkap untuk Modest Fashion', 
    category: 'Styling Guide', // Sinkron dengan list
    author: 'Budi Santoso', 
    date: '27 November 2024', // Sinkron dengan list '27 Nov 2024'
    readTime: 4, 
    image: '/gamis.png', // Sinkron dengan list
    lead: 'Aksesoris yang tepat bisa mengangkat penampilanmu. Simak rekomendasi aksesoris terbaik mulai dari belt, tas, hingga perhiasan untuk melengkapi gaya modest Anda tanpa berlebihan.', 
    content: [
      { 
        heading: '1. Belt untuk Siluet Defined', 
        paragraphs: [
          'Belt (ikat pinggang) adalah aksesori penting untuk gamis *loose*. Pilih *slim belt* berwarna netral (hitam, cokelat) untuk menciptakan siluet pinggang yang lebih ramping dan rapi.'
        ]
      },
      { 
        heading: '2. Statement Scarf atau Shawl', 
        paragraphs: [
          'Jika busana Anda polos, tambahkan *statement scarf* dengan motif atau warna cerah. Shawl berpayet cocok untuk acara malam, menambahkan kesan mewah instan.'
        ], 
        tips: [
          { title: 'Busana Polos', description: 'Gunakan scarf bermotif' },
          { title: 'Busana Motif', description: 'Gunakan scarf warna solid' }
        ]
      },
      { 
        heading: '3. Perhiasan dan Tas yang Tepat', 
        paragraphs: [
          'Gunakan perhiasan minimalis (anting kecil, kalung rantai). Untuk tas, pilih *clutch* atau *mini bag* untuk acara formal dan *tote bag* elegan untuk kasual.'
        ],
        image: '/aksesoris-detail.png',
        imageCaption: 'Tas dan perhiasan yang melengkapi modest look.'
      }
    ], 
    conclusion: 'Jangan remehkan kekuatan aksesoris. Sedikit sentuhan belt atau tas yang tepat bisa membuat penampilan modest Anda naik kelas.', 
    tags: ['aksesoris', 'styling', 'modest fashion', 'belt', 'shawl'] 
  },

  // ARTIKEL 8 (DISINKRONKAN)
  { 
    id: 8, 
    title: 'Modest Fashion untuk Acara Pernikahan', 
    category: 'Fashion Tips', // Sinkron dengan list
    author: 'Rahmawati', 
    date: '26 November 2024', // Sinkron dengan list '26 Nov 2024'
    readTime: 7, 
    image: '/koko.png', // Sinkron dengan list
    lead: 'Tampil anggun dan sopan di acara pernikahan dengan pilihan outfit modest yang stylish. Panduan memilih warna, bahan, dan potongan yang sesuai dengan suasana pesta.', 
    content: [
      { 
        heading: '1. Pilihan Bahan Elegan', 
        paragraphs: [
          'Pilih gamis atau setelan dengan bahan yang memberikan kesan mewah seperti *velvet, satin*, atau *tulle brokat*. Warna-warna seperti *emerald green, navy*, atau *maroon* adalah pilihan klasik nan elegan.'
        ]
      },
      { 
        heading: '2. Model dan Potongan yang Anggun', 
        paragraphs: [
          'Abaya dengan potongan A-line yang jatuh sempurna atau gamis bertingkat (ruffle) adalah pilihan bagus. Hindari pakaian yang terlalu ketat atau yang terlalu santai seperti katun biasa.'
        ], 
        tips: [
          { title: 'Acara Malam', description: 'Pilih warna gelap dengan sentuhan shimmer atau payet' },
          { title: 'Acara Siang', description: 'Pilih warna pastel, hindari terlalu banyak kilau' }
        ]
      },
      { 
        heading: '3. Hijab dan Footwear yang Serasi', 
        paragraphs: [
          'Kenakan hijab berbahan satin atau *silk* yang di-styling rapi. Lengkapi dengan heels atau wedges yang nyaman, dan jangan lupakan *clutch bag* yang *matching*.'
        ],
        image: '/kondangan-style.png',
        imageCaption: 'Tampil elegan di acara pernikahan dengan gamis satin dan hijab silk.'
      }
    ], 
    conclusion: 'Dengan perencanaan yang tepat, Anda bisa tampil sopan, modis, dan anggun di setiap acara pernikahan.', 
    tags: ['pernikahan', 'modest fashion', 'fashion tips', 'kondangan', 'gamis'] 
  },

  // ARTIKEL 9 (DISINKRONKAN)
  { 
    id: 9, 
    title: 'Trend Hijab 2024: Dari Pashmina hingga Turkish', 
    category: 'Trend 2024', // Sinkron dengan list
    author: 'Siti Nurhaliza', 
    date: '25 November 2024', // Sinkron dengan list '25 Nov 2024'
    readTime: 5, 
    image: '/koko-hijau.png', // Sinkron dengan list
    lead: 'Berbagai style hijab yang sedang trending dan cara memakainya untuk berbagai bentuk wajah. Tahun 2024 menawarkan keragaman style yang elegan dan praktis.', 
    content: [
      { 
        heading: '1. Revival Pashmina Sifon', 
        paragraphs: [
          'Pashmina sifon kembali populer. Style yang longgar dan menjuntai memberikan kesan elegan dan minimalis. Cocok dipadukan dengan busana kasual maupun formal.'
        ]
      },
      { 
        heading: '2. Style Turkish Simpel', 
        paragraphs: [
          'Style Turkish yang rapi, menutupi leher, dan tidak terlalu banyak lilitan sangat digemari karena memberikan kesan profesional dan bersih. Cocok untuk pergi ke kantor atau acara resmi.'
        ], 
        tips: [
          { title: 'Pashmina', description: 'Cocok untuk wajah bulat, memberi efek panjang' },
          { title: 'Turkish', description: 'Cocok untuk wajah oval/heart, memberikan kesan rapi' }
        ]
      },
      { 
        heading: '3. Square Scarf dengan Pin Minimalis', 
        paragraphs: [
          'Jilbab segiempat (square scarf) tetap klasik. Trennya kini adalah pin minimalis atau tanpa pin, diikat sederhana di bagian belakang atau dilepas menjuntai di dada.'
        ],
        image: '/pashmina-style.png',
        imageCaption: 'Style pashmina yang menjuntai memberikan kesan minimalis.'
      }
    ], 
    conclusion: 'Tren hijab 2024 mengarah pada gaya yang elegan, simpel, dan praktis. Kunci utama adalah memilih bahan yang nyaman dan *styling* yang sesuai dengan bentuk wajah Anda.', 
    tags: ['hijab', 'trend 2024', 'pashmina', 'turkish', 'modest wear'] 
  },
  
  // ARTIKEL 10 (Tetap seperti sebelumnya)
  { 
    id: 10, 
    title: 'Mengenal Kain Shimmer: Tren Busana Pesta 2025', 
    category: 'Material Insight',
    author: 'Ani Fadillah', 
    date: '10 November 2025', 
    readTime: 4, 
    image: '/shimmer.png', 
    lead: 'Kain shimmer atau berkilau menjadi sensasi di dunia fashion modest tahun 2025.', 
    content: [{ heading: '1. Apa Itu Kain Shimmer?', paragraphs: ['Kain shimmer adalah jenis material yang ditenun atau dilapisi dengan benang metalik atau foil yang sangat halus, memberikan efek kilau lembut saat terkena cahaya.'] }], 
    conclusion: 'Kain shimmer menawarkan cara mudah untuk tampil glamor di acara pesta.', 
    tags: ['shimmer', 'pesta', 'material', 'trend 2025', 'fashion'] 
  }
];

// Data Artikel Terkait (Mengambil 3 artikel terakhir dari array fullArticlesData)
const relatedArticlesData = fullArticlesData.map(article => ({
    id: article.id,
    title: article.title,
    category: article.category,
    image: article.image,
    date: article.date,
}));

// Export data agar bisa diimpor
export { fullArticlesData, relatedArticlesData };