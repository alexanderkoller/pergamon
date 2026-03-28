#import "/src/content-to-string.typ": capitalize-first, content-to-string

// capitalize-first on strings
#assert.eq("Hello", capitalize-first("hello"))
#assert.eq("Hello", capitalize-first("Hello"))
#assert.eq("", capitalize-first(""))
#assert.eq(none, capitalize-first(none))

// capitalize-first on content
#assert.eq("Hello", content-to-string(capitalize-first([hello])))
#assert.eq("Hello world", content-to-string(capitalize-first([hello world])))

// capitalize non-ASCII letters
#assert.eq("Äpfel", capitalize-first("äpfel"))
#assert.eq("Äpfel", content-to-string(capitalize-first([äpfel])))
