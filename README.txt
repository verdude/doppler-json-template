The following command write secrets to the named pipe, disregarding json objects/arrays.

doppler run --mount .env.json -- jq . .env.json

Every secret is treated as a string.
Furthermore, the computed value type is not attached to the secrets.
This forces the application to parse the secret strings into whatever datatype they are meant to be.
This requires a mapping in the application code or writing some parser to determine the expected type.
Doppler provides a --mount-template flag for the run command that may use golang formatting.
The issue here is that we must still provide a complete mapping of the secrets we would like as well as any type transformations.

The doppler cli has a `secrets` command that fetches the secrets from the api along with the type information.
This program transforms the output from `doppler secrets --json` into an appropriate template file to be used with the `doppler run --mount ... --mount-template ...` command.

Usage example:

`doppler secrets -p projectname -c configname --json | doppler-json-template | tee projectname.tmpl`

`doppler run -p projectname -c configname --mount .env.json --mount-format projectname.tmpl -- jq . .env.json`
