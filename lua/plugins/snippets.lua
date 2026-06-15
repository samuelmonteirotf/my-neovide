--------------------------------------------------------------------------------
-- DevOps snippet pack (LuaSnip, already bundled by LazyVim).
--
-- Type a trigger and press <Tab>:
--   dockerfile          → multi-stage-ready Dockerfile skeleton
--   k8s yaml: deploy / svc / ing / cm / ns
--   terraform: res / var / out / mod / data
--   yaml (CI): ghaction → GitHub Actions workflow skeleton
--   ansible: task / play
--------------------------------------------------------------------------------

return {
  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.setup(opts)

      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ----------------------------------------------------------------------
      -- Dockerfile
      ----------------------------------------------------------------------
      ls.add_snippets("dockerfile", {
        s("dockerfile", {
          t("FROM "),
          i(1, "alpine:3.20"),
          t({ "", "", "WORKDIR " }),
          i(2, "/app"),
          t({ "", "", "COPY . .", "", "RUN " }),
          i(3, "true"),
          t({ "", "", 'CMD ["' }),
          i(4, "app"),
          t('"]'),
          i(0),
        }),
      })

      ----------------------------------------------------------------------
      -- Kubernetes manifests (plain yaml)
      ----------------------------------------------------------------------
      ls.add_snippets("yaml", {
        s("deploy", {
          t({ "apiVersion: apps/v1", "kind: Deployment", "metadata:", "  name: " }),
          i(1, "app"),
          t({ "", "spec:", "  replicas: " }),
          i(2, "1"),
          t({ "", "  selector:", "    matchLabels:", "      app: " }),
          i(3, "app"),
          t({ "", "  template:", "    metadata:", "      labels:", "        app: " }),
          i(4, "app"),
          t({ "", "    spec:", "      containers:", "        - name: " }),
          i(5, "app"),
          t({ "", "          image: " }),
          i(6, "image:tag"),
          t({ "", "          ports:", "            - containerPort: " }),
          i(7, "8080"),
          i(0),
        }),
        s("svc", {
          t({ "apiVersion: v1", "kind: Service", "metadata:", "  name: " }),
          i(1, "app"),
          t({ "", "spec:", "  selector:", "    app: " }),
          i(2, "app"),
          t({ "", "  ports:", "    - port: " }),
          i(3, "80"),
          t({ "", "      targetPort: " }),
          i(4, "8080"),
          i(0),
        }),
        s("ing", {
          t({ "apiVersion: networking.k8s.io/v1", "kind: Ingress", "metadata:", "  name: " }),
          i(1, "app"),
          t({ "", "spec:", "  rules:", "    - host: " }),
          i(2, "example.com"),
          t({
            "",
            "      http:",
            "        paths:",
            "          - path: /",
            "            pathType: Prefix",
            "            backend:",
            "              service:",
            "                name: ",
          }),
          i(3, "app"),
          t({ "", "                port:", "                  number: " }),
          i(4, "80"),
          i(0),
        }),
        s("cm", {
          t({ "apiVersion: v1", "kind: ConfigMap", "metadata:", "  name: " }),
          i(1, "app-config"),
          t({ "", "data:", "  " }),
          i(2, "key"),
          t(": "),
          i(3, "value"),
          i(0),
        }),
        s("ns", {
          t({ "apiVersion: v1", "kind: Namespace", "metadata:", "  name: " }),
          i(1, "team"),
          i(0),
        }),
        s("ghaction", {
          t({ "name: " }),
          i(1, "CI"),
          t({
            "",
            "on:",
            "  push:",
            "    branches: [main]",
            "  pull_request:",
            "    branches: [main]",
            "",
            "jobs:",
            "  ",
          }),
          i(2, "build"),
          t({ ":", "    runs-on: ubuntu-latest", "    steps:", "      - uses: actions/checkout@v4", "      - name: " }),
          i(3, "Run"),
          t({ "", "        run: " }),
          i(4, "make test"),
          i(0),
        }),
      })

      ----------------------------------------------------------------------
      -- Terraform / HCL
      ----------------------------------------------------------------------
      ls.add_snippets("terraform", {
        s("res", {
          t('resource "'),
          i(1, "type"),
          t('" "'),
          i(2, "name"),
          t({ '" {', "  " }),
          i(0),
          t({ "", "}" }),
        }),
        s("data", {
          t('data "'),
          i(1, "type"),
          t('" "'),
          i(2, "name"),
          t({ '" {', "  " }),
          i(0),
          t({ "", "}" }),
        }),
        s("var", {
          t('variable "'),
          i(1, "name"),
          t({ '" {', "  type        = " }),
          i(2, "string"),
          t({ "", '  description = "' }),
          i(3, ""),
          t({ '"', "}" }),
          i(0),
        }),
        s("out", {
          t('output "'),
          i(1, "name"),
          t({ '" {', "  value = " }),
          i(2, ""),
          t({ "", "}" }),
          i(0),
        }),
        s("mod", {
          t('module "'),
          i(1, "name"),
          t({ '" {', '  source = "' }),
          i(2, "./modules/x"),
          t({ '"', "  " }),
          i(0),
          t({ "", "}" }),
        }),
      })

      ----------------------------------------------------------------------
      -- Ansible (yaml.ansible)
      ----------------------------------------------------------------------
      ls.add_snippets("yaml.ansible", {
        s("task", {
          t("- name: "),
          i(1, "describe the task"),
          t({ "", "  " }),
          i(2, "ansible.builtin.command"),
          t({ ":", "    " }),
          i(0),
        }),
        s("play", {
          t("- name: "),
          i(1, "play name"),
          t({ "", "  hosts: " }),
          i(2, "all"),
          t({ "", "  become: true", "  tasks:", "    - name: " }),
          i(3, "first task"),
          t({ "", "      ansible.builtin.ping:" }),
          i(0),
        }),
      })
    end,
  },
}
