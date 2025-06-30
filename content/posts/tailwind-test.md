---
title: "Tailwind CSS & Solarized Theme Test"
date: 2025-06-30
draft: true
---

Testing Tailwind CSS integration with Solarized color scheme:

<div class="bg-blue-500 text-white p-4 rounded-lg mb-6">
  <h2 class="text-2xl font-bold mb-2">Tailwind is Working!</h2>
  <p class="text-lg">This box should have a blue background with white text.</p>
</div>

## Solarized Terminal Theme

Here's a dark terminal-style code block using the Solarized theme:

<div class="terminal mb-4">
<div class="terminal-prompt">hugo server --buildDrafts</div>
<div class="text-sl-cyan">Starting Hugo development server...</div>
<div class="comment"># This is a comment</div>
<div><span class="keyword">const</span> <span class="variable">tailwind</span> <span class="operator">=</span> <span class="string">"awesome"</span><span class="operator">;</span></div>
<div><span class="function">console.log</span><span class="operator">(</span><span class="variable">tailwind</span><span class="operator">);</span></div>
</div>

And here's the light version:

<div class="terminal-light mb-4">
<div class="terminal-prompt">npm run build-css</div>
<div class="text-sl-blue">Building Tailwind CSS...</div>
<div class="comment"># Light theme example</div>
<div><span class="keyword">function</span> <span class="function">buildSite</span><span class="operator">()</span> <span class="operator">{</span></div>
<div>&nbsp;&nbsp;<span class="keyword">return</span> <span class="string">"success"</span><span class="operator">;</span></div>
<div><span class="operator">}</span></div>
</div>

## Inline Code Examples

Here's some <span class="inline-code">inline code</span> with the dark theme, and here's <span class="inline-code-light">inline code</span> with the light theme.

<div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
  <div class="bg-sl-base2 text-sl-base01 p-4 rounded border border-sl-base1">
    <h3 class="text-sl-blue font-semibold">Solarized Light Box</h3>
    <p class="text-sl-base00">Using Solarized light colors.</p>
  </div>
  <div class="bg-sd-base02 text-sd-base0 p-4 rounded border border-sd-base01">
    <h3 class="text-sl-cyan font-semibold">Solarized Dark Box</h3>
    <p class="text-sd-base1">Using Solarized dark colors.</p>
  </div>
</div>