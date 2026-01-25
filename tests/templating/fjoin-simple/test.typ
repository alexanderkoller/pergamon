#import "/src/templating.typ": *

Hello World

#assert.eq("foo, bar", content-to-string(fjoin(",", [foo], [bar])))
#assert.eq("foo, bar,", content-to-string(fjoin(",", [foo], [bar], finish-with-connector: true)))

#assert.eq(" X", spaces("", "x"))
#assert.eq("x ", spaces("x", ""))