<template>
  <div class="pt-0 dark:bg-black dark:text-white"> 
    <!-- Hero Section -->
    <section class="relative w-full h-[200px] sm:h-[280px] md:h-[320px] overflow-hidden">
      <img 
        src="/collect.png" 
        alt="Collections" 
        class="w-full h-full object-cover object-center"
      >
      <div class="absolute inset-0 flex items-center justify-center">
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-serif 
                   text-black dark:text-white">
          Collections
        </h1>
      </div>
    </section>

    <!-- Koleksi -->
    <div class="w-full max-w-screen-2xl mx-auto px-6 sm:px-8 py-16">
      <div class="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        
        <div 
          v-for="collection in collections" 
          :key="collection.name" 
          class="relative group cursor-pointer overflow-hidden rounded-lg"
        >
          <img 
            :src="collection.image" 
            :alt="collection.name" 
            class="w-full h-64 sm:h-72 md:h-80 lg:h-96 object-cover 
                   transition-transform duration-300 group-hover:scale-110"
          >
          
          <!-- Overlay -->
          <div 
            class="absolute inset-0 
                   bg-black bg-opacity-30 
                   dark:bg-black dark:bg-opacity-40 
                   flex items-center justify-center">
            <h3 
              class="font-serif text-white text-xl sm:text-2xl font-semibold">
              {{ collection.name }}
            </h3>
          </div>
        </div>
        
      </div>
    </div>
  </div>
</template>

<script setup>
const collections = [
  { name: 'Gamis', image: '/gamis.png' },
  { name: 'Koko', image: '/koko.png' },
  { name: 'Abaya', image: '/abaya.png' },
  { name: 'Accessories', image: '/akse.png' },
]
</script>
