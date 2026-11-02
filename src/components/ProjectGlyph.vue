<script setup>
defineProps({
  tone: {
    type: String,
    default: 'mint',
  },
})
</script>

<template>
  <div :class="['glyph', `glyph-${tone}`]" aria-hidden="true">
    <div class="glyph-window">
      <span class="glyph-dots">
        <i />
        <i />
        <i />
      </span>
      <div class="glyph-content">
        <span />
        <span />
        <span />
      </div>
    </div>
    <div class="glyph-shape" />
  </div>
</template>

