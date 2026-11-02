<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
  },
  size: {
    type: String,
    default: 'default',
  },
  type: {
    type: String,
    default: 'button',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

const buttonClasses = computed(() => [
  'btn',
  props.variant === 'outline' ? 'btn-outline' : '',
  props.variant === 'ghost' ? 'btn-ghost' : '',
  props.size === 'sm' ? 'btn-sm' : '',
  props.size === 'icon' ? 'btn-icon' : '',
])
</script>

<template>
  <button :type="type" :disabled="disabled" :class="buttonClasses">
    <slot />
  </button>
</template>

