#!/bin/bash

		##########################################################################
		##	1.) Do the fresh pod deployment if first time			##
		##########################################################################

set -u

## Variables defined
image_version=0.0.1-SNAPSHOT
baseDir=deploy
deploymentName=rest-service
deploymentYaml=deploy.yaml
hpaYaml=hpa.yaml

## Get the deployment status
header=`kubectl get deployment | head -1`
isDeployed=`kubectl get deployment | awk -v dn="$deploymentName" '$1 ~ dn {print}'`

## Check if the deployment already running
if [ -z "${isDeployed}" ]; then
	printf "\nDeployment is not running, going to deploy for the first time.\n"
	kubectl create -f ${baseDir}/${deploymentYaml}
	sleep 5
	printf "\n${deploymentName} service was deployed.Checking the deployment status...\n"
	isDeployedNow=`kubectl get deployment | awk -v dn="$deploymentName" '$1 ~ dn {print}'`

	printf "\n====\n${header}\n${isDeployedNow}\n====\n"

else
	#sed -i "/image:/ s/:[0-9].[0-9].[0-9]/:$image_version/" ${baseDir}/${deploymentYaml}
	currentPodImage=`kubectl get pods -o jsonpath="{..image}" | sed 's/ /\n/g' | awk -F ':' -v dsn="${deploymentName}" '$2 ~ dsn {print $3}' | sort | uniq`
	printf "\n${deploymentName} deployment is already running, will update the image to the deployment.\n"
	printf "\nCurrent deployed image for ${deploymentName} deployment: ${currentPodImage}\n"

	## Check if this image already deployed?
	if [ "${image_version}" = "${currentPodImage}" ]; then
        	printf "\nImage-version: ${image_version} is already deployed to ${deploymentName}. Exiting...!\n"
			printf "\n\n===== DOCKER IMAGE WASN'T DEPLOYED TO POD =====\n\n"
	else
        	printf "\nImage-version: ${image_version} will be deployed to ${deploymentName}.\n"
			kubectl apply -f ${baseDir}/${deploymentYaml}
			kubectl apply -f ${baseDir}/${hpaYaml}
			sleep 5
	fi

	isDeployedNow=`kubectl get deployment | awk -v dn="$deploymentName" '$1 ~ dn {print}'`
	printf "\n==== kubectl get deployment ====\n${header}\n${isDeployedNow} \n"
fi

podStatus=`kubectl get pods | awk -v dn="$deploymentName" '$1 ~ dn {print}'`
printf "\n============= Pods Status ===============\n"
printf "\n${podStatus}\n"
printf "\n=========================================\n"
printf "\nSCRIPT COMPLETED!!\n"
