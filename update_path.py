with open(".github/workflows/build.yml", "r") as f:
    content = f.read()

old_path = "workspace/out/target/product/RMX3760/*.img"
new_path = "workspace/out/target/product/**/*.img"

if old_path in content:
    content = content.replace(old_path, new_path)
    with open(".github/workflows/build.yml", "w") as f:
        f.write(content)
    print("Path updated successfully!")
else:
    print("Path pattern not exact, updating via sed...")
