#!/bin/bash

source utilities.sh
utilities_stdout_msg="${0##*/} BEGIN"
utilities_debug_off; utilities_stdout_message; utilities_debug_on

###########
# Constants
###########
project_root=$(pwd)

args=( "$@" )
valid_arg_keys=('-h' '-and_push' '-no_prompts' '-tag_name')
valid_key_only_args=('-h' '-and_push' '-no_prompts')

############
# Variables.
############
tag_name=""
no_prompts=$FALSE
sudo_str=""

########################
# Subroutines
########################
usage () {
  set +x
  echo "Usage: ${0##*/} [-h] [-and_push] [-no_prompts] [-tag_name] <git_tag_name>"
  echo " "
  echo "Description: Merge from upstream to fork."
  echo "Parameters:"
  echo "       -h:          display usage help."
  echo "       -and_push:   also push the docker images"
  echo "       -no_prompts: set script to be non-interactive"
  echo "       -tag_name:   name of git tag for all projects"
  echo "               <git_tag_name> - git tag name to checkout"
  exit
}

processArgs() {
  source processArgs.sh

  # New way to get key only valid args, returns TRUE if provided, otherwise returns FALSE
  utilities_argument_key='h'
  help_flag=$(utilities_argument_provided)
  if [ "$help_flag" = "$TRUE" ]
  then
    usage
  fi

  utilities_argument_key='and_push'
  and_push=$(utilities_argument_provided)
  if [ "$and_push" = "$TRUE" ]
  then
    utilities_stdout_msg="Git PUSH option enabled."
    utilities_msg_info; utilities_debug_on
  fi

  utilities_argument_key='no_prompts'
  no_prompts=$(utilities_argument_provided)
  if [ "$no_prompts" = "$TRUE" ]
  then
    utilities_stdout_msg="Script will run non-interactive."
    utilities_msg_info; utilities_debug_on
  fi

  # New way to set values from valid args array
  utilities_argument_key='tag_name'
  tag_name=$(utilities_get_index_for_value_from_arguments_array)
  if [ "$tag_name" != "" ]
  then
    utilities_stdout_msg="Git tag name for git checkout: ${tag_name}."
    utilities_msg_info; utilities_debug_on
  fi
  
  # Validate argument combinations
  #if [ "$userid" = "" ] || [ "$host_ip" = "" ]
  #then
  #  echo "ERROR: '-userid' and '-host_ip' are required arguments."
  #  usage
  #fi
}

#====================
# Constants
#TRUE=1
#start_time=$(date +%s)
#current_dir=`pwd`

get_search_path() {
  # Note: this function uses the language inherient behaviour of parsing
  # input of a string argument with spaces, e.g. /root/my search path/temp

  local search_dir="ERROR LOCATING SEARCH_PATH"
  if [ $# -lt 2 ]
  then
    # return error string
    echo "${search_dir}: $1"
    return
  fi

  # Save the beginning of the search path, e.g $2=/root my
  search_dir=$2

  # Process each token of the parameters
  let token_count=1
  for input_token in "$@"
  do
    # Append any any tokens after $2, e.g $3=search $$4=path/temp
    if (( token_count > 2 )) 
    then
      search_dir="$search_dir $input_token"
    fi
    let token_count+=1
  done

  # return string
  echo $search_dir
}

already_processed() {
  local current_path=$1

  # Get to array parameter
  shift

  local previous_paths=("$@")
  #echo "List of previous paths: ${previous_paths[@]}"
  for previous_dir in ${previous_paths[@]}
  do
    #echo "Comparing current path: -${current_path}- to previous path: -${previous_dir}-."
    if [[ "$current_path" == "$previous_dir" ]]
    then
      return 1
    fi
  done
  # return string
  return 0
}

deep_copy_array() {
  local new_array=( ) 
  local source_array=("$@")
  
  if [ "${#source_array[@]}" -eq 0 ]
  then
    #echo "SOURCE ARRAY IS SIZE 0, SHOULD HAVE BEEN SIZE SIZE OF: $@"
    return 1
  fi

  local let index=0
  for array_element in ${source_array[@]}
  do
    #echo "ASSIGNING ${array_element} TO NEW_ARRAY[$index]."
    new_array[$index]=$array_element
    let index+=1
  done
  if [ "${#source_array[@]}" -eq 0 ]
  then
    #echo "SOURCE ARRAY IS SIZE 0, SHOULD HAVE BEEN SIZE SIZE OF: $@"
    return -1
  else
    if [ "${#new_array[@]}" -eq "${#source_array[@]}" ]
    then
      echo "${new_array[@]}"
    else
      #echo "NEW_ARRAY(${#new_array[@]}) != SOURCE_ARRAY(${#source_array[@]})"
      return -1
    fi
  fi
}

check_for_unmerged_files() {
  # Unmerged changes exists?
  unmerged_changes="${TRUE}"
  unmerged_files=$(git ls-files -m)
  if [ "$unmerged_files" = "" ]
  then
    unmerged_changes="${FALSE}"
  fi

  echo "${unmerged_changes}"
}

prompt_to_abort_processing() {
  utilities_debug_off
  if [ "$no_prompts" = "$FALSE" ]
  then

    if [[ "$abort_cmd" != "" ]]
    then 
      echo -n "COMMAND: ${abort_cmd}. "
    fi
  
    echo -n "Proceed (y/n)?: "
    read ans
    if [ "$ans" != "y" ]
    then
      utilities_stdout_msg="${abort_msg}"
      utilities_exit_with_error
    fi
  fi
  utilities_debug_on
}

upstream_merge_master() {
  # Move to master branch if needed
  if [ "$current_branch_name" != "master" ]
  then
    abort_cmd="git checkout master"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
    git checkout master

    abort_cmd="git fetch all";  abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
    git fetch --all

    branch_name=$(git symbolic-ref --short HEAD)
    if [ "$branch_name" != "master" ]
    then
      utilities_stdout_msg="Switch to master branch from ${branch_name} failed, unable to proceed.  ${stash_warning}"
      utilities_exit_with_error
    fi
  fi

  utilities_debug_off
  # Fetch some changes from upstream
  abort_cmd="git fetch upstream"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git fetch upstream
  #git fetch upstream master

  # Merge fetched changes
  abort_cmd="git merge upstream/master"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git merge upstream/master
  rt_code=$?

  abort_cmd="git merge upstream/master COMPLETED with return_code=${rt_code}"; abort_msg="Aborted after merging with upstream master, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing
  local rt_code=$?

  utilities_debug_off
  # Push changes to local fork
  abort_cmd="git push"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git push
  rt_code=$?

  abort_cmd="git push COMPLETED with return_code=${rt_code}"; abort_msg="Aborted after pushing upstream merges to master, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing
}

upstream_merge_non_master() {
  abort_cmd="git checkout $current_branch_name"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git checkout $current_branch_name
 
  branch_name=$(git symbolic-ref --short HEAD)
  if [ "$branch_name" != "$current_branch_name" ] 
  then
    utilities_stdout_msg="Switch to ${current_branch_name} failed, unable to proceed.  ${stash_warning}"
    utilities_exit_with_error
  fi
     
  utilities_debug_off
  # Merge fetched changes
  abort_cmd="git merge master";  abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git merge master
  rt_code=$?

  abort_cmd="git merge master COMPLETED with return_code=${rt_code}"; abort_msg="Aborted after merge with master, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing

  # Check if this branch is new to the remote origin
  branch_name_exists_in_remote=$(git branch -a | grep "origin/$branch_name")
  local new_remote_origin_branch_param=""
  if [ "$branch_name_exists_in_remote" = "" ]
  then
    # Add a paramenter to create the new branch in the reomte origin
    new_remote_origin_branch_param='--set-upstream'
  fi
      
  utilities_debug_off
  # Push changes to local fork
  abort_cmd="git push $new_remote_origin_branch_param origin $branch_name"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git push $new_remote_origin_branch_param origin $branch_name
  rt_code=$?

  abort_cmd="git push $new_remote_origin_branch_param origin $branch_name COMPLETED with return_code=${rt_code}"; abort_msg="Aborted after pushing merges from master to ${current_branch_name}, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing

}

upstream_merge() {
  # Stash any current changes if needed
  stash_warning=""
  unmerged_files=$(check_for_unmerged_files)
  if [ "$unmerged_files" == "$TRUE" ]
  then
    # If there are changes in the master branch halt everything.  This should not occur ever.
    if [ "$current_branch_name" == "master" ]
    then
      utilities_debug_off
      git status
      utilities_stdout_msg="Unmerged files exists in master branch of project: ${project}, unable to proceed."
      utilities_exit_with_error
    fi

    utilities_debug_off
    abort_cmd="git stash"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
    git stash
    echo "return_code=$?"
    stash_warning="WARNING: STASHED CHANGES HAVE NOT BEEN RE-APPLIED."

    abort_cmd=""; abort_msg="Aborted after stashing current changes, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing
  fi

  # Remember to unstash after merge if needed
  unstash_after_merge="${unmerged_files}"

  # Ensure there is no unmerged changes after stash completes
  unmerged_files=$(check_for_unmerged_files)
  if [ "$unmerged_files" == "$TRUE" ]
  then
    utilities_debug_off
    git status
    utilities_stdout_msg="Unmerged files still exists in project: ${project}, unable to proceed.  ${stash_warning}"
    utilities_exit_with_error
  fi

  # Merge with master branch first
  upstream_merge_master

  # If working with a branch the merge changes to the branch as well
  if [ "$tag_name" = "" ] && [ "$current_branch_name" != ""  ] && [ "$current_branch_name" != "master" ]
  then
    upstream_merge_non_master

    # Unstash working changes
    if [ "$unstash_after_merge" == "$TRUE" ]
    then
      
      utilities_debug_off
      abort_cmdi="git stash apply"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
      git stash apply
      echo "return_code=$?"

      abort_cmd=""; abort_msg="Aborted after unstashing changes in ${current_branch_name}, unable to proceed.  ${stash_warning}"; prompt_to_abort_processing
    fi
  else
    # Now process tags if provided in the arguments
    if [ "$tag_name" != "" ]
    then
      abort_cmd="git checkout tags/$tag_name"; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
      git checkout tags/$tag_name
      local co_return_code=$?
      echo "return_code=${co_return_code}"
      abort_cmd=""; abort_msg="Aborted after doing a checkout of tag: ${tag_name}, unable to proceed."; prompt_to_abort_processing
    fi
  fi # Process merge in non-master branch
}

build_project() {
  utilities_debug_on
  if [ -f glide.yaml ]
  then
    # Install any new dependencies
    glide cc
    glide install
  fi

  if [ ! -f Makefile ]
  then
    echo "0"
    return
  fi

  # Build the project
  build_output=$(make docker-build 2>&1)
  local return_code=$?

  # If failed build then abort
  if [ "$return_code" != "0" ]
  then
    echo "${build_output}"
    utilities_stdout_msg="Aborted after trying to build ${project}, unable to proceed."
    utilities_exit_with_error
  fi

  if [ "$and_push" = "$TRUE" ]
  then
    push_output=$(make docker-push 2>&1)
    local return_code=$?

    # If failed push then abort
    if [ "$return_code" != "0" ]
    then
      echo "${push_output}"
      utilities_stdout_msg="Aborted after trying to push images for: ${project}, unable to proceed."
      utilities_exit_with_error
    fi
  fi
  #echo "${build_output}"
  #abort_msg="Aborted after trying to do a docker build for ${project}, unable to proceed."
  #if [ "$no_prompts" = "$FALSE" ]; then prompt_to_abort_processing; fi
}

 
process_project() {
  utilities_stdout_msg="Starting merge of project."; utilities_msg_info; utilities_debug_on
 
  # Get current starting branch
  current_branch_name=$(git symbolic-ref --short HEAD)

  # Make sure it is ok to run this script with master branch
  utilities_debug_off
  if [[ "$current_branch_name" = "master" ]]
  then
    abort_cmd='CURRENT BRANCH IS --master--.'; abort_msg="Aborted: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
    sleep 3
    abort_cmd='CURRENT BRANCH IS --master--.'; abort_msg="Aborted: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  else
    abort_cmd="CURRENT BRANCH IS: --${current_branch_name}--"; abort_msg="Aborted: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  fi
  utilities_debug_on

  # Check to see if this project has an upstream/master remote
  utilities_debug_off
  abort_cmd='git show-branch remotes/upstream/master'; abort_msg="Aborted before issuing: ${abort_cmd}, unable to proceed."; prompt_to_abort_processing
  git show-branch remotes/upstream/master
  local rt_code=$?

  abort_cmd="git show-branch remotes/upstream/master COMPLETED with return_code=${rt_code}"; abort_msg="Aborted after checking for upstream master remote, unable to proceed."; prompt_to_abort_processing

  # If the project has an upstream/master this indicates a fork so do a merge, otherwise fail.
  if [ "$rt_code" == "0" ]
  then
    # Merge changes from upstream
    upstream_merge
  else
    utilities_stdout_msg="Aborted after checking for upstream master remote with unknown return code: ${return_code}, unable to proceed."
    utilities_exit_with_error
  fi
}

########################
# Main
########################

# Process the input arguement parameters
processArgs 

if [ "$userid" != "root" ]
then
  sudo_str="sudo"
fi


# Start at DLaaS root dir
pwd

# Process project
process_project

# Cleanup
IFS=${orig_IFS}
exit 0

