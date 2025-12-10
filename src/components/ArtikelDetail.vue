<template>
  <div class="min-h-screen bg-white dark:bg-black transition-colors duration-300">
    <div v-if="article" class="w-full">
      <section class="relative w-full h-[300px] sm:h-[400px] md:h-[500px] overflow-hidden">
        <img 
          :src="article.image" 
          :alt="article.title"
          class="w-full h-full object-cover object-center"
        >
        <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent"></div>
        
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

      <article class="max-w-4xl mx-auto px-6 sm:px-8 py-12 md:py-16">
        <p class="text-lg sm:text-xl text-gray-700 dark:text-gray-300 leading-relaxed mb-8 font-medium">
          {{ article.lead }}
        </p>

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

            <ul v-if="section.tips" class="list-disc list-inside space-y-3 my-6 ml-4">
              <li v-for="(tip, tIndex) in section.tips" :key="tIndex" class="text-gray-700 dark:text-gray-300">
                <span class="font-semibold">{{ tip.title }}:</span> {{ tip.description }}
              </li>
            </ul>
          </div>
        </div>

        <div class="mt-12 p-6 sm:p-8 bg-gray-50 dark:bg-gray-900 rounded-lg">
          <h3 class="font-serif text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Kesimpulan
          </h3>
          <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
            {{ article.conclusion }}
          </p>
        </div>

        <div class="mt-8 flex flex-wrap gap-2">
          <span 
            v-for="tag in article.tags" 
            :key="tag"
            class="px-4 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 text-sm rounded-full"
          >
            #{{ tag }}
          </span>
        </div>

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

      <section class="bg-gray-50 dark:bg-gray-900 py-16 transition-colors">
        <div class="max-w-6xl mx-auto px-6 sm:px-8">
          <h2 class="font-serif text-3xl font-bold text-gray-900 dark:text-white mb-8">
            Artikel Terkait
          </h2>
          
          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-8">
            <RouterLink 
              v-for="related in filteredRelatedArticles" 
              :key="related.id"
              :to="`/artikel/${related.id}`"
              class="block"
            >
              <article 
                class="bg-white dark:bg-gray-800 rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all group cursor-pointer h-full flex flex-col"
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
                
                <div class="p-6 flex flex-col flex-grow">
                  <h3 class="font-serif text-lg font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2 group-hover:text-seera-gold dark:group-hover:text-[#C99F53] transition-colors flex-grow">
                    {{ related.title }}
                  </h3>
                  
                  <div class="flex items-center justify-between pt-4 border-t dark:border-gray-700 mt-auto">
                    <span class="text-xs text-gray-500 dark:text-gray-400">
                      {{ related.date }}
                    </span>
                    <span class="text-seera-gold dark:text-[#C99F53] text-sm font-semibold hover:underline">
                      Baca →
                    </span>
                  </div>
                </div>
              </article>
            </RouterLink>
          </div>
        </div>
      </section>

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
    <div v-else class="text-center py-20 text-gray-700 dark:text-gray-300">
      Artikel tidak ditemukan atau sedang dimuat...
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router' 

// --- IMPOR DATA DARI FILE TERPISAH ---
import { fullArticlesData, relatedArticlesData } from '../data/articles' 
// Catatan: Asumsi path file adalah '@/data/articles'. Sesuaikan dengan struktur folder Anda.

const route = useRoute()
const article = ref(null)

const allRelatedArticles = ref(relatedArticlesData) // Menggunakan data yang diimpor

const filteredRelatedArticles = computed(() => {
    // Saring artikel terkait agar tidak menyertakan artikel yang sedang dilihat
    return allRelatedArticles.value.filter(related => related.id !== article.value?.id)
})

// Fungsi untuk mengambil data artikel
const fetchArticleData = (id) => {
    // Cari data di array yang sudah diimpor
    const foundArticle = fullArticlesData.find(a => a.id === Number(id))
    article.value = foundArticle || null
    
    // Scroll ke atas halaman saat artikel baru dimuat
    if (foundArticle) {
      window.scrollTo(0, 0)
    }
}

// Ambil data pertama kali saat komponen dimuat
onMounted(() => {
    fetchArticleData(route.params.id)
})

// Perhatikan perubahan pada route.params.id (ketika pindah dari artikel satu ke artikel lain)
watch(
    () => route.params.id,
    (newId) => {
        if (newId) {
            fetchArticleData(newId)
        }
    }
)
</script>