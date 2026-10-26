export function normalizePhone(phone: string): string {
  if (!phone) return '';
  // Remove non-digit characters except leading +
  let cleaned = phone.trim().replace(/[^\d+]/g, '');
  if (!cleaned.startsWith('+')) {
    // Default country prefix if not present e.g. +1 or +254
    if (cleaned.startsWith('0')) {
      cleaned = '+254' + cleaned.substring(1);
    } else {
      cleaned = '+' + cleaned;
    }
  }
  return cleaned;
}

export function isValidPhone(phone: string): boolean {
  const normalized = normalizePhone(phone);
  return /^\+\d{7,15}$/.test(normalized);
}
