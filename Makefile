.PHONY: provision_sandbox

provision_sandbox:
	ansible-playbook -i hosts/sandbox --vault-password-file ../vault-key server-sandbox.yml