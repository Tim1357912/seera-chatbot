const configuredAssetBase = import.meta.env.VITE_ASSET_BASE_URL?.replace(/\/+$/, '')

export function assetUrl(path) {
  const normalizedPath = path.replace(/^\/+/, '')
  if (configuredAssetBase) {
    return `${configuredAssetBase}/${normalizedPath}`
  }
  return `/${normalizedPath}`
}
