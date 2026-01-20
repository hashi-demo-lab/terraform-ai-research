# Prompt Duplication & Optimization Analysis Report

**Date:** January 20, 2026  
**Scope:** Analysis of 4 files/folders in `ai-iac-consumer-template`
- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.claude/CLAUDE.md`
- `.claude/skills/terraform-style-guide/` (folder)

---

## Table 1: Duplicated Instructions Across Files

| Duplication Theme | File 1 (Location) | File 2 (Location) | Statement Comparison | Recommendations/Next Steps | Final Decision |
|---|---|---|---|---|---|
| **Private Module Registry First** | AGENTS.md L7 | constitution.md L16-24 | Both mandate using private registry. AGENTS.md: "ALWAYS verify module by searching the HCP Terraform private registry using MCP tools" vs constitution.md provides detailed implementation rules | | |
| **Use `search_private_modules` tool** | AGENTS.md L54-55 | constitution.md L21 | Both: "Use MCP `search_private_modules`" repeated with similar phrasing | | |
| **Never hardcode credentials** | AGENTS.md L45 | constitution.md L53-54 | AGENTS.md: "Hardcode credentials" (NEVER DO) vs constitution.md: "MUST never generate static, long-lived credentials" | | |
| **terraform validate** | AGENTS.md L38 | constitution.md L399 | Both require running `terraform validate` after code generation | | |
| **terraform fmt** | constitution.md L398 | SKILL.md L58-60 | Both mandate `terraform fmt` before commit | | |
| **File structure** | AGENTS.md L79-91 | constitution.md L139-149 | Nearly identical file structure lists with slight naming variations (`provider.tf` vs `providers.tf`) | | |
| **Spec-first/Specification-driven development** | AGENTS.md L6 | constitution.md L39-47 | AGENTS.md: "NEVER generate code without `/speckit.implement`" vs constitution.md explains rationale and implementation | | |
| **Use subagents** | AGENTS.md L40 | CLAUDE.md L30-32 | Both: "Use subagents for quality evaluation" / "use subagents liberally" | | |
| **Parallel tool calls** | AGENTS.md L60 | CLAUDE.md L32 | Both mention parallel calls: "user parrallel calls" vs "use parrallel tool calls" (typos in both) | | |
| **Variables must have type & description** | constitution.md L175-177 | SKILL.md L308-316 | Both mandate type+description for all variables | | |
| **Sensitive variables** | constitution.md L177 | SKILL.md L315 | Both: mark sensitive variables with `sensitive = true` | | |
| **Pre-commit hooks** | constitution.md L81-90 | SKILL.md L71-76 | Both recommend git pre-commit hooks for fmt/validate | | |
| **snake_case naming** | constitution.md L161 | SKILL.md L212-215 & AVM.md L113-119 | All three mandate snake_case with underscores | | |
| **Version constraints (`~>`)** | constitution.md L34, L199 | SKILL.md L648-656 | Both require pessimistic version constraints | | |
| **No public access to modules** | constitution.md L24-29 | AGENTS.md L48 | Both prohibit public registry without approval | | |
| **Prompt for unknown values** | AGENTS.md L74 | constitution.md L667 | Both: "Prompt user for unknown values (NEVER guess)" | | |
| **Meta-arguments first** | constitution.md L155 | SKILL.md L130-143 & AVM.md L155-168 | All three specify meta-arguments come first | | |
| **Code quality judge subagent** | constitution.md L203 | constitution.md L241 | Same file, repeated twice at L203 and L241 | | |
| **Ephemeral workspace testing** | constitution.md L318-341 | constitution.md L557-594 | Same file, duplicated sections X.1 and IV.1 | | |

---

## Table 2: Contradictions/Inconsistencies

| Issue | File 1 (Location) | File 2 (Location) | Contradiction | Recommendations/Next Steps | Final Decision |
|---|---|---|---|---|---|
| **MCP `create_run` usage** | AGENTS.md L49, L68 | constitution.md L342-343 | AGENTS.md: "NEVER use MCP create_run" vs constitution.md: "use `create_run` to create a new Terraform run" | | |
| **File naming: provider.tf vs providers.tf** | AGENTS.md L85 | constitution.md L145 | AGENTS.md: `provider.tf` vs constitution.md: `providers.tf` | | |
| **terraform.tf content** | AGENTS.md L86 | constitution.md L146-147 | AGENTS.md: "Version constraints" vs constitution.md: "backend configuration for testing" (conflicting purposes) | | |
| **Override file purpose** | AGENTS.md L87 | constitution.md L147 | Both mention `override.tf` for HCP backend but constitution.md also assigns this to `terraform.tf` | | |
| **Comments style** | SKILL.md L61 | constitution.md code examples | SKILL.md: "Use `#` for comments (avoid `//` and `/* */`)" but code examples in constitution.md use `/* */` | | |

---

## Table 3: Language Optimization Opportunities (Claude 4 Best Practices)

Reference: [Claude 4 Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)

| Issue | Location | Current Language | Recommended Change | Rationale | Recommendations/Next Steps | Final Decision |
|---|---|---|---|---|---|---|
| **Aggressive "MUST/NEVER" overuse** | All files | "MUST", "NEVER", "CRITICAL" repeated extensively | Reduce intensity. Use "Use X when..." instead of "CRITICAL: You MUST use X" | Claude 4.x is more responsive to system prompts; aggressive language causes over-triggering | | |
| **Typo: "parrallel"** | AGENTS.md L60, CLAUDE.md L32 | "user parrallel calls" / "use parrallel tool calls" | Fix to "parallel" | Typos reduce instruction clarity | | |
| **Typo: "iterative improvment"** | AGENTS.md L10 | "iterative improvment" | "iterative improvement" | Spelling error | | |
| **Typo: "your intending"** | AGENTS.md L57 | "resources your intending on creating" | "resources you're intending to create" | Grammar error | | |
| **Redundant rationale blocks** | constitution.md L17-19, L41-43 | Extensive "Rationale" paragraphs | Move to external docs; keep prompts concise | Claude 4.5 prefers direct instructions; context can be brief | | |
| **Excessive markdown formatting** | constitution.md all sections | Heavy use of `**Policy**:`, `**Standard**:`, etc. | Simplify structure; use plain headings | Reduces token overhead; Claude works well with simpler formatting | | |
| **Duplicate pre-commit instructions** | constitution.md L81-90, L234 | Pre-commit mentioned twice with scripts | Consolidate to one section with reference | Token efficiency | | |
| **Long code examples** | constitution.md L323-335 | Multi-line bash scripts inline | Reference external scripts or use shorter examples | Token efficiency | | |
| **Tell what to do, not what NOT to do** | AGENTS.md L43-50 | "NEVER DO" list of 7 items | Reframe positively: "Always do X" instead of "Never do Y" | Claude 4 best practice: tell Claude what to do instead of what not to do | | |
| **Redundant instructions across files** | CLAUDE.md references AGENTS.md | Points to AGENTS.md but then adds overlapping instructions | Choose one source of truth; CLAUDE.md should only reference | Reduces confusion and token usage | | |
| **Word "think" usage** | Multiple files | N/A currently | Avoid "think" when extended thinking disabled; use "consider", "evaluate" | Claude 4.5 is sensitive to "think" variants | | |
| **Section numbering inconsistency** | constitution.md L209, L243, L299 | Sections jump from III to IV to V with 3.x numbering mixed | Fix section numbering (3.1-3.3 under Section IV is wrong) | Consistency improves comprehension | | |

---

## Summary Recommendations

### 1. Consolidate into Single Source of Truth
| Recommendation | Details | Recommendations/Next Steps | Final Decision |
|---|---|---|---|
| AGENTS.md as primary | Should be the primary instruction file for AI agents | | |
| constitution.md as reference | Should be referenced context, not duplicated instructions | | |
| SKILL.md stays separate | Remains as a standalone skill reference | | |

### 2. Resolve Contradictions
| Contradiction | Resolution Needed | Recommendations/Next Steps | Final Decision |
|---|---|---|---|
| `create_run` policy | Clarify MCP vs CLI usage | | |
| File naming standard | Standardize `provider.tf` vs `providers.tf` | | |
| Internal duplications | Fix ephemeral workspace sections in constitution.md | | |

### 3. Token Efficiency Improvements
| Improvement | Impact | Recommendations/Next Steps | Final Decision |
|---|---|---|---|
| Remove duplicate "Rationale" explanations | Reduce token count | | |
| Consolidate repeated instructions | Pre-commit appears 3+ times | | |
| Use bullet lists | Replace verbose paragraphs | | |
| Reduce excessive formatting | Remove excessive **bold** and markdown | | |

### 4. Apply Claude 4 Best Practices
| Practice | Current State | Recommended Change | Recommendations/Next Steps | Final Decision |
|---|---|---|---|---|
| Reduce aggressive language | "MUST/NEVER/CRITICAL" overused | Use normal language | | |
| Frame positively | "NEVER DO" lists | State what TO do vs what NOT to do | | |
| Fix typos | Multiple typos identified | Correct all spelling/grammar | | |
| Remove redundant context | Extensive rationales in-prompt | Move to external docs | | |

---

## Token Count Estimate

| File | Approximate Token Count | Notes |
|---|---|---|
| AGENTS.md | ~800 tokens | Concise but has duplications |
| constitution.md | ~6,000+ tokens | Very verbose; high optimization potential |
| CLAUDE.md | ~300 tokens | Mostly references; some duplication |
| terraform-style-guide/ (folder) | ~4,000+ tokens | Comprehensive but overlaps with constitution |
| **Total** | ~11,000+ tokens | Potential 30-40% reduction with consolidation |

---

*Report generated for prompt optimization review*
