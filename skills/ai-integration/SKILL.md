---
name: ai-integration
description: "AI/LLM feature integration — streaming, prompt engineering, RAG, embeddings, structured output in production apps"
triggers:
  - "ai integration"
  - "add ai features"
  - "llm integration"
  - "streaming"
  - "ai chat"
  - "embeddings"
  - "structured output"
---

# AI Integration — LLM Features in Production

## When to Invoke

Use when adding AI-powered features to an application — chat interfaces, text generation, search, summarization, structured extraction, or any LLM-powered functionality.

## Architecture Decisions

### 1. Where does inference run?

| Approach | Pros | Cons | Use When |
|----------|------|------|----------|
| API (Claude, OpenAI, etc.) | Best quality, no infra | Latency, cost, data leaves | Most production apps |
| Self-hosted (Ollama, vLLM) | Data stays local, predictable cost | Worse quality, GPU needed | Privacy-critical, high volume |
| Edge (small models) | Fast, cheap | Limited capability | Simple classification, embeddings |

### 2. Streaming vs Batch

```typescript
// Streaming (for user-facing generation)
const response = await anthropic.messages.stream({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  messages: [{ role: "user", content: prompt }],
})

for await (const event of response) {
  if (event.type === "content_block_delta") {
    yield event.delta.text
  }
}

// Batch (for background processing)
const response = await anthropic.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  messages: [{ role: "user", content: prompt }],
})
```

**Rule:** Stream for anything the user watches. Batch for anything background.

### 3. Structured Output

```typescript
// Force structured responses with tool_use
const response = await anthropic.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  tools: [{
    name: "extract_data",
    description: "Extract structured data from text",
    input_schema: {
      type: "object",
      properties: {
        sentiment: { type: "string", enum: ["positive", "negative", "neutral"] },
        topics: { type: "array", items: { type: "string" } },
        summary: { type: "string", maxLength: 200 },
      },
      required: ["sentiment", "topics", "summary"],
    },
  }],
  tool_choice: { type: "tool", name: "extract_data" },
  messages: [{ role: "user", content: text }],
})
```

## Common Patterns

### Chat Interface

```tsx
// Server action for streaming
"use server"
export async function chat(messages: Message[]) {
  const stream = await anthropic.messages.stream({
    model: "claude-sonnet-4-6-20250514",
    max_tokens: 4096,
    system: "You are a helpful assistant.",
    messages: messages.map(m => ({ role: m.role, content: m.content })),
  })
  return stream.toReadableStream()
}

// Client consumption
const [messages, setMessages] = useState<Message[]>([])
const [streaming, setStreaming] = useState("")

async function send(content: string) {
  const userMsg = { role: "user", content }
  setMessages(prev => [...prev, userMsg])

  const response = await chat([...messages, userMsg])
  const reader = response.getReader()
  const decoder = new TextDecoder()

  let full = ""
  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    full += decoder.decode(value)
    setStreaming(full)
  }
  setMessages(prev => [...prev, { role: "assistant", content: full }])
  setStreaming("")
}
```

### RAG (Retrieval-Augmented Generation)

```typescript
// 1. Embed the query
const queryEmbedding = await embed(query)

// 2. Search vector store
const results = await vectorStore.search(queryEmbedding, { topK: 5 })

// 3. Generate with context
const response = await anthropic.messages.create({
  model: "claude-sonnet-4-6-20250514",
  system: `Answer based on the following context:\n\n${results.map(r => r.content).join("\n\n")}`,
  messages: [{ role: "user", content: query }],
})
```

### Prompt Caching (save cost on repeated context)

```typescript
const response = await anthropic.messages.create({
  model: "claude-sonnet-4-6-20250514",
  system: [
    {
      type: "text",
      text: longSystemPrompt,      // This gets cached
      cache_control: { type: "ephemeral" },
    }
  ],
  messages: [{ role: "user", content: userQuestion }],
})
```

## Production Concerns

### Rate Limiting & Queuing

```typescript
// Client-side: debounce user input
const debouncedQuery = useDebouncedValue(query, 300)

// Server-side: queue with retry
import { Ratelimit } from "@upstash/ratelimit"
const ratelimit = new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(10, "1m") })
```

### Error Handling

```typescript
try {
  const response = await anthropic.messages.create(params)
} catch (e) {
  if (e.status === 429) {
    // Rate limited — retry with exponential backoff
    await delay(Math.pow(2, attempt) * 1000)
    return retry()
  }
  if (e.status === 529) {
    // Overloaded — show fallback UI
    return { error: "Service busy, try again in a moment" }
  }
  // 400 = bad request (our bug), 500 = their bug
  throw e
}
```

### Cost Control

- Set `max_tokens` to the minimum needed
- Use smaller models for simple tasks (Haiku for classification, Sonnet for generation)
- Cache repeated prompts (prompt caching)
- Batch similar requests when possible
- Monitor spend with usage tracking

### Security

- Never expose API keys to the client (server-side only)
- Sanitize user input before including in prompts (prevent injection)
- Validate structured outputs before trusting them
- Don't let users control the system prompt
- Rate limit per user to prevent abuse

## Model Selection

| Task | Recommended Model |
|------|-------------------|
| Complex reasoning, code gen | Claude Opus 4.8 |
| General purpose, chat | Claude Sonnet 4.6 |
| Fast classification, extraction | Claude Haiku 4.5 |
| Embeddings | voyage-3 or text-embedding-3-small |

## Output

```markdown
## AI Integration

**Features added**: [chat, search, extraction, summarization, etc.]
**Model**: [which, why]
**Streaming**: [yes/no]
**RAG**: [yes/no, vector store used]
**Cost estimate**: [per request, monthly projected]
**Security**: [key management, rate limiting, input validation]
```
