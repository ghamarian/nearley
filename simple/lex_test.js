const moo = require('moo')

let lexer = moo.compile({
    space: {match: /\s+/, lineBreaks: true},
    number: /-?(?:[0-9]|[1-9][0-9]+)(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?\b/,
    string: /"(?:\\["bfnrt\/\\]|\\u[a-fA-F0-9]{4}|[^"\\])*"/,
    '{': '{',
    '}': '}',
    '[': '[',
    ']': ']',
    ',': ',',
    ':': ':',
    true: 'true',
    false: 'false',
    null: 'null',
})


lexer.reset('{"amir": "ehsan"}')
console.log(lexer.next())// -> { type: 'keyword', value: 'while' }
console.log(lexer.next())// -> { type: 'WS', value: ' ' }
console.log(lexer.next())// -> { type: 'lparen', value: '(' }
console.log(lexer.next())// -> { type: 'number', value: '10' }
// ...