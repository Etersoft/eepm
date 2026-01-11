# epm search

Search packages in repositories.

## Usage

```
epm search [options] pattern [pattern...]
```

## Options

- `--short` - output package names only (without descriptions)
- `--regexp` - treat patterns as regular expressions (for grep filter)

## Search Patterns

By default, patterns support glob syntax:

| Pattern | Meaning |
|---------|---------|
| `*` | Match any characters |
| `?` | Match single character |
| `[abc]` | Match any character in brackets |
| `[a-z]` | Match character range |
| `[!abc]` | Match any character NOT in brackets |
| `~pattern` | Exclude packages matching pattern |

### Examples

```bash
# Simple search
epm search firefox

# Multiple patterns (AND logic)
epm search firefox web

# Glob patterns
epm search 'lib*-devel'
epm search 'python3?'
epm search 'lib[0-9]*'

# Exclude pattern
epm search firefox ~esr

# Regular expressions (with --regexp)
epm search --regexp 'firefox.*esr'
epm search --regexp '^lib[0-9]+'
```

## How It Works

1. The longest word from patterns is used for package manager search
2. Results are filtered with grep using all patterns
3. Package names are highlighted in output

## See Also

- `epm play --search` - search installable applications
- `epm list --available` - list all available packages
