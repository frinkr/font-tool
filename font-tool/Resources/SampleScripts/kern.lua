function filterFont(font)
   -- check if has 'kern' feature
   return font.openTypeFeatures['kern']
end
