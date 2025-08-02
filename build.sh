mkdir -p out
for file in bug-report.md feature.md progress.md resolve.md plan.md ideate.md orient.md implement.md prototype.md code-review.md decompose.md next-up.md harden.md reflect.md research.md debug.md recall.md checkpoint.md; do
  deno run --allow-read --allow-write build.ts "$file" "out/commands/$file"
done
