<template>
  <div>
    <Hero />
    <Collections />
    <ProductGrid title="New Arrival" :products="newArrivals" />
    <ProductGrid title="Best Seller" :products="bestSellers" />
    <Testimonials />
  </div>
</template>

<script setup>
import Hero from '../components/Hero.vue'
import Collections from '../components/Collections.vue'
import ProductGrid from '../components/ProductGrid.vue'
import Testimonials from '../components/Testimonials.vue'
import { assetUrl } from '../utils/assets'

const newArrivals = [
  { id: 1, name: 'Koko Pria', price: 'Rp250.000', discount: 'New In', image: assetUrl('koko-putih.png') },
  { id: 2, name: 'Gamis Wanita', price: 'Rp280.000', discount: 'New In', image: assetUrl('gamis-pink.png') },
  { id: 3, name: 'Koko Pria', price: 'Rp290.000', discount: 'New In', image: assetUrl('koko-abu.png') },
  { id: 4, name: 'Koko Pria', price: 'Rp200.000', discount: 'New In', image: assetUrl('gamis-coklat.png') },
]

const bestSellers = [
  { id: 5, name: 'Koko Pria Casual', price: 'Rp220.000', image: assetUrl('koko-hijau.png') },
  { id: 6, name: 'Abaya Wanita Syari', price: 'Rp300.000', image: assetUrl('abaya-hitam.png')  },
  { id: 7, name: 'Gamis Executive', price: 'Rp350.000', image: assetUrl('gamis-p.png') },
  { id: 8, name: 'Hijab Trendy', price: 'Rp240.000', image: assetUrl('hijab.png') },
]
</script>
