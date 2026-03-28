#import "/src/templating.typ": *

#assert.eq("foo.. bar", content-to-string(fjoin(".", [foo.], [bar])))

// skip-if
#assert.eq("foo. bar", content-to-string(fjoin(".", [foo.], [bar], skip-if: pc => pc == ".")))
#assert.eq("foo? bar", content-to-string(fjoin(".", [foo?], [bar], skip-if: pc => pc in ".,?!;:")))

// skip-if with strings
#assert.eq("foo. bar", content-to-string(fjoin(".", [foo.], [bar], skip-if: ".")))
#assert.eq("foo? bar", content-to-string(fjoin(".", [foo?], [bar], skip-if: ".,?!;:")))
#assert.eq("foo-. bar", content-to-string(fjoin(".", [foo-], [bar], skip-if: ".,?!;:")))

#assert.eq("foo.", content-to-string(fjoin(".", [foo], finish-with-connector: true)))
#assert.eq("foo.", content-to-string(fjoin(".", [foo.], finish-with-connector: true, skip-if: ".")))

// capitalize
#assert.eq("Operating System. research report", fjoin(".", "Operating System", "research report"))
#assert.eq(str, type(fjoin(".", "Operating System", "research report")))
#assert.eq("Operating System. Research report", fjoin(".", "Operating System", "research report", capitalize-after: ".!?"))

// capitalize content after period
#assert.eq("Operating System. Research report", content-to-string(fjoin(".", [Operating System], [research report], capitalize-after: ".!?")))

// capitalize content: none elements skipped, capitalization still applies
#assert.eq("Operating System. Research report", content-to-string(fjoin(".", [Operating System], none, [research report], capitalize-after: ".!?")))

// capitalize content: first element is not capitalized
#assert.eq("research report. Test", content-to-string(fjoin(".", [research report], [test], capitalize-after: ".!?")))

// capitalize content: mixed string and content
#assert.eq("Operating System. Research report", content-to-string(fjoin(".", "Operating System", [research report], capitalize-after: ".!?")))
