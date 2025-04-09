/**
  This dynamic router is included as an example.

  By creating this router, I learned a lot about the state of
  the Navigation API in 2025. It's highly versatle and simple
  to implement.

  Compared to older hacks like popstate and having to manually
  handle history events, I found it very straightforward to use.

  You just hook into the 'navigate' event and intercept the
  default handler. You ignore the types of events you don't
  want to handle, then call your own router function. This
  whole router is just a handler and renderer, all thanks to
  the Navigation API.

  Unfortunately, the Navigation API is still unsupported in
  Safari & Firefox, so this router is unusable in production.

  https://developer.mozilla.org/en-US/docs/Web/API/Navigation_API#browser_compatibility

  Reddit uses a shim for the Navigation API, which experiences
  issues: https://github.com/webcompat/web-bugs/issues/136535

  I chose to hit the GitHub API rather than use Octokit
  (https://github.com/octokit/core.js#readme) to avoid
  exposing my GitHub Auth Token in the client. I just
  wanted the minimal amount of stuff to render markdown
  anyways, so I stuck with my custom SSG.
*/

if (!("navigation" in window)) {
  throw new Error(
    "Pour one out 🍺 for the Navigation API, it's not supported in this browser. https://developer.mozilla.org/en-US/docs/Web/API/Navigation_API#browser_compatibility"
  );
}

const content = document.getElementById("content");

const errorPage = {
  title: "404 - Not Found",
  content: (slug) =>
    `<h1>404 - Not Found</h1><p>The page <pre>${slug}.md</pre> does not exist.</p>`,
};

async function router(url) {
  const path = new URL(url, location.origin).pathname;
  const slug = path.replace(/^\/+|\/+$/g, ""); // Remove Leading/Trailing Slash Sequences
  const file = `/markdown/${slug}.md`;

  try {
    const title = slug.replace(/-/g, " ");
    document.title = title.replace(/\b\w/g, (char) => char.toUpperCase()); // Capital Case Route Slug as the Page Title

    const markdown = await fetch(file).then((result) => {
      if (!result.ok) throw new Error("404");
      return result.text();
    });
    const html = await render(markdown);
    content.innerHTML = html;

    scrollTo(0, 0);
  } catch (error) {
    document.title = errorPage.title;
    content.innerHTML = errorPage.content(slug);
  }
}

async function render(markdown) {
  // Rate Limited to 60req/hr (Without Auth Token)
  const result = await fetch("https://api.github.com/markdown", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-GitHub-Api-Version": "2022-11-28", // Must Specify API Version (https://docs.github.com/rest/overview/api-versions)
    },
    body: JSON.stringify({ text: markdown }),
  });

  return result.text();
}

navigation.addEventListener("navigate", (event) => {
  // Ignore Reloads, Hash Changes (#links), & Downloads
  if (!event.canIntercept || event.hashChange || event.downloadRequest) return;

  event.intercept({
    handler() {
      return router(event.destination.url);
    },
  });
});
