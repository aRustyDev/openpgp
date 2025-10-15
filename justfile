set unstable := true

# This controls what keys are exported to WKD
# NOTE: if you want a key exported, tag it in 1Password with "openpgp"

root := `git rev-parse --show-toplevel`
keys := `op item list --tags openpgp --format json  2>/dev/null | jq '[.[] | {id:.id, vault:.vault.id}]'`
well_known := root + "/.well-known/openpgpkey/hu"

# Update WKD keys with all configured in 1Password
[unix]
default: mktree
    #!/usr/bin/env bash
    rm -rf "{{ well_known }}/*"
    jq -n -c --argjson k '{{ keys }}' '$k[]' | while read i; do
        vault=$(echo "$i" | jq -r '.vault')
        item=$(echo "$i" | jq -r '.id')
        just gen-wkd-hash "$vault" "$item"
    done
    just policy
    just cloudflare
    just clean

[unix]
gen-wkd-hash vault item: clean
    #!/usr/bin/env bash
    EMAIL=$(op read "op://{{ vault }}/{{ item }}/email" 2>/dev/null)
    LOCAL_PART="${EMAIL%@*}"
    # Generate the WKD hash
    WKD_HASH=$(echo -n "$LOCAL_PART" | sha1sum | cut -c1-32)
    # Download the public key
    op document get --out-file pgp.pub --vault "{{ vault }}" "{{ item }}"  2>/dev/null
    # Export as binary (NOT ASCII armored) and move to the correct location
    gpg --output "$WKD_HASH" --dearmor pgp.pub
    mv $WKD_HASH "{{ well_known }}/$WKD_HASH"
    # Verify it's binary (should show "data" or "GPG key public ring")
    file "{{ well_known }}/$WKD_HASH"

[unix]
mktree:
    #!/usr/bin/env bash
    mkdir -p "{{ well_known }}"

policy:
    #!/usr/bin/env bash
    touch ".well-known/openpgpkey/policy"

cloudflare:
    #!/usr/bin/env bash
    # Create headers file for Cloudflare Pages
    cat > _headers << 'EOF'
    /.well-known/openpgpkey/*
      Access-Control-Allow-Origin: *
      Content-Type: application/octet-stream
      Cache-Control: public, max-age=86400
    EOF

test:
    #!/usr/bin/env bash
    # Check the key file
    curl -I https://openpgpkey.example.com/.well-known/openpgpkey/hu/<wkd-hash>
    # Check the policy file
    curl -I https://openpgpkey.example.com/.well-known/openpgpkey/policy
    # Actually download and test the key
    curl https://openpgpkey.example.com/.well-known/openpgpkey/hu/<wkd-hash> -o test.key
    gpg --show-keys test.key

clean:
    @rm -f pgp.pub
