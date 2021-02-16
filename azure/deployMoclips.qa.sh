az account set -s aicoe.qa
az deployment group create -g moclips-qa-grp --template-file moclips.qa.json