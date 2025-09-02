#import "/src/templating.typ": *

#assert.eq("foo.. bar", content-to-string(fjoin(".", [foo.], [bar])))

// skip-if
#assert.eq("foo. bar", content-to-string(fjoin(".", [foo.], [bar], skip-if: pc => pc == ".")))
#assert.eq("foo? bar", content-to-string(fjoin(".", [foo?], [bar], skip-if: pc => pc in ".,?!;:")))

// skip-if with strings
#assert.eq("foo. bar", content-to-string(fjoin(".", [foo.], [bar], skip-if: ".")))
#assert.eq("foo? bar", content-to-string(fjoin(".", [foo?], [bar], skip-if: ".,?!;:")))
#assert.eq("foo-. bar", content-to-string(fjoin(".", [foo-], [bar], skip-if: ".,?!;:")))
