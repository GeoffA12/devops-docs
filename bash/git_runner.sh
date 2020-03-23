read -p "Enter your first name: " name
email=""
username=""
URL=$(git remote get-url origin)
URLsuffix="$(cut -d '/' -f 2 <<< $URL)"

if [[ "$name" == "jeff" || "$name" == "Jeff" ]]
then
	URLprefix="git@bitbucket-jeff.org:swei_team22/"
	username="jng415"
	email="jng@stedwards.edu"

elif [[ "$name" == "geoff" || "$name" == "Geoff" ]]
then
	URLprefix="git@bitbucket.org:swei_team22/"
	username="garroyo"
	email="garroyo@stedwards.edu"
else
	echo "Your name is not recognized by the script."
	exit 401
fi

replaceURL="$URLprefix$URLsuffix"
echo "New remote URL Origin set to: $replaceURL"
git remote set-url origin $replaceURL
echo "New git config email set to: $email"
git config user.email $email
echo "New git config username set to $username"
git config user.name $username
