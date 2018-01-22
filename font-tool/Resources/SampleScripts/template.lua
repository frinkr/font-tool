function filterFont(font)
   print(font.familyName .. ' ' .. font.styleName .. ' : ' )
   print('   PS Name = ' .. font.postscriptName)
   print('   Num Glyphs = ' .. font.numGlyphs)
   print('   UPEM = ' .. font.UPEM)
   print('   createdDate = ' .. font.createdDate)
   print('   modifiedDate = ' .. font.modifiedDate)
   print('   format = ' .. font.format)
   print('   isCID = ' .. tostring(font.isCID))
   print('   vender = ' .. font.vender)
   print('   version = ' .. font.version)
   return true
end
