<template>
  <div class="min-h-screen bg-white dark:bg-black transition-colors duration-300">
    <!-- Hero Image -->
    <section class="relative w-full h-[300px] sm:h-[400px] md:h-[500px] overflow-hidden">
      <img 
        :src="article.image" 
        :alt="article.title"
        class="w-full h-full object-cover object-center"
      >
      <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent"></div>
      
      <!-- Article Meta -->
      <div class="absolute bottom-0 left-0 right-0 p-6 sm:p-8 md:p-12">
        <div class="max-w-4xl mx-auto">
          <span class="inline-block bg-seera-gold text-black px-4 py-1 text-xs sm:text-sm font-semibold mb-4">
            {{ article.category }}
          </span>
          <h1 class="font-serif text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-4">
            {{ article.title }}
          </h1>
          <div class="flex items-center gap-4 text-white/90 text-sm">
            <span>{{ article.author }}</span>
            <span>•</span>
            <span>{{ article.date }}</span>
            <span>•</span>
            <span>{{ article.readTime }} menit baca</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Article Content -->
    <article class="max-w-4xl mx-auto px-6 sm:px-8 py-12 md:py-16">
      <!-- Lead Paragraph -->
      <p class="text-lg sm:text-xl text-gray-700 dark:text-gray-300 leading-relaxed mb-8 font-medium">
        {{ article.lead }}
      </p>

      <!-- Content Sections -->
      <div class="prose prose-lg dark:prose-invert max-w-none">
        <div v-for="(section, index) in article.content" :key="index" class="mb-10">
          <h2 class="font-serif text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white mb-4">
            {{ section.heading }}
          </h2>
          
          <div v-for="(paragraph, pIndex) in section.paragraphs" :key="pIndex" class="mb-6">
            <p class="text-gray-700 dark:text-gray-300 leading-relaxed mb-4">
              {{ paragraph }}
            </p>
          </div>

          <!-- Section Image (jika ada) -->
          <div v-if="section.image" class="my-8">
            <img 
              :src="section.image" 
              :alt="section.heading"
              class="w-full rounded-lg shadow-lg"
            >
            <p v-if="section.imageCaption" class="text-sm text-gray-500 dark:text-gray-400 text-center mt-3 italic">
              {{ section.imageCaption }}
            </p>
          </div>

          <!-- Tips/List (jika ada) -->
          <ul v-if="section.tips" class="list-disc list-inside space-y-3 my-6 ml-4">
            <li v-for="(tip, tIndex) in section.tips" :key="tIndex" class="text-gray-700 dark:text-gray-300">
              <span class="font-semibold">{{ tip.title }}:</span> {{ tip.description }}
            </li>
          </ul>
        </div>
      </div>

      <!-- Conclusion -->
      <div class="mt-12 p-6 sm:p-8 bg-gray-50 dark:bg-gray-900 rounded-lg">
        <h3 class="font-serif text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
          Kesimpulan
        </h3>
        <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
          {{ article.conclusion }}
        </p>
      </div>

      <!-- Tags -->
      <div class="mt-8 flex flex-wrap gap-2">
        <span 
          v-for="tag in article.tags" 
          :key="tag"
          class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 text-sm rounded-full"
        >
          #{{ tag }}
        </span>
      </div>

      <!-- Share Section -->
      <div class="mt-12 pt-8 border-t dark:border-gray-700">
        <p class="text-gray-900 dark:text-white font-semibold mb-4">Bagikan artikel ini:</p>
        <div class="flex gap-4">
          <button class="bg-blue-600 hover:bg-blue-700 text-white p-3 rounded-full transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
            </svg>
          </button>
          <button class="bg-sky-500 hover:bg-sky-600 text-white p-3 rounded-full transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" />
            </svg>
          </button>
          <button class="bg-green-600 hover:bg-green-700 text-white p-3 rounded-full transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
            </svg>
          </button>
        </div>
      </div>
    </article>

    <!-- Related Articles -->
    <section class="bg-gray-50 dark:bg-gray-900 py-16 transition-colors">
      <div class="max-w-6xl mx-auto px-6 sm:px-8">
        <h2 class="font-serif text-3xl font-bold text-gray-900 dark:text-white mb-8">
          Artikel Terkait
        </h2>
        
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-8">
          <article 
            v-for="related in relatedArticles" 
            :key="related.id"
            class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all group cursor-pointer"
          >
            <div class="relative overflow-hidden">
              <img 
                :src="related.image" 
                :alt="related.title"
                class="w-full h-48 object-cover group-hover:scale-110 transition-transform duration-300"
              />
              <span class="absolute top-4 left-4 bg-black/70 text-white px-3 py-1 text-xs font-semibold">
                {{ related.category }}
              </span>
            </div>
            
            <div class="p-6">
              <h3 class="font-serif text-lg font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2 group-hover:text-seera-gold dark:group-hover:text-[#C99F53] transition-colors">
                {{ related.title }}
              </h3>
              
              <div class="flex items-center justify-between pt-4 border-t dark:border-gray-700">
                <span class="text-xs text-gray-500 dark:text-gray-400">
                  {{ related.date }}
                </span>
                <span class="text-seera-gold dark:text-[#C99F53] text-sm font-semibold">
                  Baca →
                </span>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>

    <!-- Back Button -->
    <div class="max-w-4xl mx-auto px-6 sm:px-8 py-8">
      <RouterLink to="/artikel">
        <button class="flex items-center gap-2 text-seera-gold dark:text-[#C99F53] font-semibold hover:underline">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Kembali ke Artikel
        </button>
      </RouterLink>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

// Sample article data - in real app, this would come from route params/API
const article = ref({
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
      heading: '5. Bermain dengan Aksesoris',
      paragraphs: [
        'Aksesoris adalah game changer dalam styling gamis. Belt dapat menciptakan siluet yang lebih defined, sementara scarf atau shawl dapat menambah dimensi pada outfit.',
        'Untuk tampilan lebih edgy, tambahkan topi fedora atau bucket hat. Tas yang tepat juga penting - clutch untuk formal, tote bag untuk casual, crossbody untuk praktis.'
      ]
    },
    {
      heading: '6. Pilihan Footwear yang Tepat',
      paragraphs: [
        'Sepatu adalah elemen penting yang sering diabaikan. Heels atau wedges untuk acara formal, sneakers atau flat shoes untuk casual, dan sandal untuk tampilan santai di musim panas.',
        'Pastikan warna sepatu match atau komplementer dengan warna gamis. Sepatu nude atau hitam adalah pilihan aman yang cocok untuk semua warna gamis.'
      ]
    },
    {
      heading: '7. Perhatikan Fabric dan Texture',
      paragraphs: [
        'Mixing textures dapat membuat outfit lebih interesting. Gamis dengan bahan matte bisa dikombinasikan dengan outer berbahan satin, atau gamis katun dengan cardigan rajut.',
        'Di musim hujan, pilih bahan yang cepat kering. Di musim panas, prioritaskan bahan yang breathable seperti katun atau linen.'
      ]
    },
    {
      heading: '8. Color Coordination',
      paragraphs: [
        'Menguasai color wheel sangat membantu dalam styling. Warna komplementer (berlawanan di color wheel) menciptakan kontras yang bold, sementara warna analog (berdekatan) menciptakan harmony.',
        'Monochromatic look dengan berbagai shade dari satu warna juga sangat elegant dan mudah untuk diterapkan.'
      ]
    },
    {
      heading: '9. Sesuaikan dengan Bentuk Tubuh',
      paragraphs: [
        'Tidak semua gamis cocok untuk semua bentuk tubuh. A-line cocok untuk hampir semua bentuk tubuh, straight cut cocok untuk tubuh langsing, sementara empire waist cocok untuk menyamarkan perut.',
        'Gunakan belt untuk menciptakan waistline jika gamis terlalu loose. Layer dengan outer yang structured untuk bentuk tubuh yang lebih defined.'
      ]
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
})

const relatedArticles = ref([
  {
    id: 2,
    title: 'Tren Warna Hijab Favorit di 2025',
    category: 'Trend 2025',
    image: '/koko.png',
    date: '2 Des 2025'
  },
  {
    id: 3,
    title: 'Panduan Memilih Koko Modern untuk Pria',
    category: 'Styling Guide',
    image: '/koko-hijau.png',
    date: '1 Des 2025'
  },
  {
    id: 4,
    title: 'Review: Koleksi Abaya Premium Seera',
    category: 'Product Review',
    image: '/gamis.png',
    date: '30 Nov 2025'
  }
])
</script>