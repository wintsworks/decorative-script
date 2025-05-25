# Decorative Script / Decorative-Script

## What is it?

```markdown
A semantic, multi-paradigm language, where functional paradigms are encouraged, but not required.

It's an experiment into how functional we can create logic with the most concise syntax possible, while retaining semantic meaning.

Inspired by a few languages I find most useful in my own day-to-day, such as Python, Go, Dlang, JavaScript.
```

## Example syntax ideas

### Normal

```go
func print_item($item):
    println "The item printed is ${item}"

for(key: value ~ list1) find (math.mean) finished: (print_item)
```

### Shorthand

```go
print_item($item) => println

for (key, value; list1) [math.mean] => print_item 
```

### Important

```markdown
=> denotes a function, and can treat loops as functions.
```

### HTTP Methods for REST

```go

app,
db: "connection string"

    get "/users/:id":
        println(db->where
                    users.id = id)

    post "/users"
        println(db->where
                    users.id = id)
```

## Other Ideas

```markdown
- A future decorative language inspired by metaprogrammming.
- Makes use of Dlang or D to leverage metaprogramming (eventually).
- Functional-first, where:
  - Function signatures also define logic where applicable.
  - To create semantic and concise syntax.
```

### Network-First Programming

```markdown
There are plans to create concise syntax for handling XML/HTTP Methods/etc without making the process difficult, or require much configuration.
```

### Machine Learning and Data Science

```markdown
- Plans to interop TensorFlow with C/C++ bindings.
      - Will likely use adapters to accomplish this as well.
  - Will also make use of built-in Dlang functions.
```
  
## Why does it exist?

```markdown
I've always aspired to make a programming language, even if unpopular. I think it's a great learning tool, and I've always wanted to make the landscape even easier to understand.

College Student here so, I will work on whenever possible, and to fuel further academic studies - so you may see syntax change over a period of time.
```
