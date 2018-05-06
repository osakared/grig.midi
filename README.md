# haxe music midi

This is alpha no real proof it actually works right yet!

To do:

* Test with more than just one midi file to ensure it's actually properly reading midi files
* Support writing midi files
* Support communicating with midi port
* Support playing midi streams (perhaps this belongs in a different lib)
* Figure out why I can't build js version (`haxe -cp tests -cp src -main RunTests -dce full -lib tink_unittest -resource tests/bohemian_rhapsody.mid -js bin/test.js`)
* Add CI
