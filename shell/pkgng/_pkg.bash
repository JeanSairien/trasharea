_pkg_installed () {
    pkg query "%n-%v"
}

_pkg_available_name () {
    pkg rquery "%n"
}

_pkg_available () {
    pkg rquery "%n-%v"
}

_pkg () {

    local cur prev opts lopts
    COMPREPLY=()

    # get command name
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # get first arguments
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # init opts for first completion
    opts='add audit autoremove backup check clean create delete
          fetch help info install query rquery search set shell
          shlib stats update updating upgrade version which'

    # init lopts for second completion with details
    lopts=( 'add[Registers a package and installs it on the system]'
            'audit[Reports vulnerable packages]'
            'autoremove[Removes orphan packages]'
            'backup[Backs-up and restores the local package database]'
            'check[Checks for missing dependencies and database consistency]'
            'clean[Cleans old packages from the cache]'
            'create[Creates software package distributions]'
            'delete[Deletes packages from the database and the system]'
            'fetch[Fetches packages from a remote repository]'
            'help[Displays help information]'
	    'info[Displays information about installed packages]'
            'install[Installs packages from remote package repositories]'
            'query[Queries information about installed packages]'
            'register[Registers a package into the local database]'
            'remove[Deletes packages from the database and the system]'
            'repo[Creates a package repository catalogue]'
            'rquery[Queries information in repository catalogues]'
            'search[Performs a search of package repository catalogues]'
            'set[Modifies information about packages in the local database]'
            'shell[Opens a debug shell]'
            'shlib[Displays which packages link against a specific shared library]'
            'stats[Displays package database statistics]'
            'update[Updates package repository catalogues]'
            'updating[Displays UPDATING information for a package]'
            'upgrade[Performs upgrades of packaged software distributions]'
            'version[Displays the versions of installed packages]'
            'which[Displays which package installed a specific file]' )

    # switch on second arguments
    case "${prev}" in 

 	add) 
	    COMPREPLY=( $(compgen -A file *.t?z ) ) && \
		return 0 ;;

        audit) 
	    COMPREPLY=( 
		'-F[Fetch the database before checking.]'
		'-q[Quiet]'
		$(compgen -F _pkg_installed) 
	    )
	    return 0 ;;

        autoremove) 
	    COMPREPLY=( $(compgen) ) && \
		return 0 ;;

        backup) 
	    COMPREPLY=() && \
		return 0 ;;

        check) 
	    COMPREPLY=() && \
		return 0 ;;

        clean) 
	    return 0 ;;
	
        create) 
	    COMPREPLY=() && \
		return 0 ;;

        delete|remove) 
	    COMPREPLY=() && \
		return 0 ;;

        fetch) 
	    COMPREPLY=() && \
		return 0 ;;

        help) 
	    COMPREPLY=() && \
		return 0 ;;

        info) 
	    COMPREPLY=() && \
		return 0 ;;

        install) 
	    COMPREPLY=() && \
		return 0 ;;

        query) 
	    COMPREPLY=() && \
		return 0 ;;

        register) 
	    COMPREPLY=() && \
		return 0 ;;

        repo) 
	    COMPREPLY=() && \
		return 0 ;;

        rquery) 
	    COMPREPLY=(
		'(-g -x -X -e)-a[Process all packages]'
		'(-x -X -a -e)-g[Process packages that matches glob]'
		'(-g -X -a -e)-x[Process packages that matches regex]'
		'(-g -x -a -e)-X[Process packages that matches extended regex]'
		'(-g -x -X -a)-e[Process packages that matches the evaluation]'
	    )
	    return 0 ;;

        search) 
	    COMPREPLY=(
		'(-x -X)-g[Process packages that matches glob]'
		'(-g -X)-x[Process packages that matches regex]'
		'(-g -x)-X[Process packages that matches extended regex]'
	    )
	    return 0 ;;

        set) 
	    COMPREPLY=(
		'(-o)-A[Mark as automatic or not]'
		'(-A)-o[Change the origin]'
		'-y[Assume yes when asked for confirmation]'
		'(-g -x -X)-a[Process all packages]'
		'(-x -X -a)-g[Process packages that matches glob]'
		'(-g -X -a)-x[Process packages that matches regex]'
		'(-g -x -a)-X[Process packages that matches extended regex]'
	    )
	    return 0 ;;

        shell) 
	    COMPREPLY=() && \
		return 0 ;;

        shlib) 
	    COMPREPLY=() && \
		return 0 ;;

        stats) 
	    COMPREPLY=(
		'-q[Be quiet]'
		'(-l)-r[Display stats only for the local package database]'
		'(-r)-l[Display stats only for the remote package database(s)]' 
	    )
	    return 0 ;;

        update) 
	    COMPREPLY=(
		'-f[Force updating]'
		'-q[Be quiet]'
	    )
	    return 0 ;;

        updating) 
	    COMPREPLY=(
		'-d[Only entries newer than date are shown]'
		'-f[Defines a alternative location of the UPDATING file]'
	    )
	    return 0 
	    ;;

        upgrade) 
	    COMPREPLY=(
		'(-y)-n[Assume no (dry run) for confirmations]' 
		'(-n)-y[Assume yes when asked for confirmation]' 
		'-f[Upgrade/Reinstall everything]' 
		'-L[Do not try to update the repository metadata]'
	    )
	    return 0 
	    ;;

        version) 
	    COMPREPLY=(
		'(-P -R)-I[Use INDEX file]'
		'(-R -I)-P[Force checking against the ports tree]'
		'(-I -P)-R[Use remote repository]'
		'-o[Display package origin, instead of package name]'
		'-q[Be quiet]'
		'-v[Be verbose]'
		'(-L)-l[Display only the packages for given status flag]'
		'(-l)-L[Display only the packages without given status flag]'
	    )
	    return 0 
	    ;;

        which) 
	    COMPREPLY=( $(compgen -W "$(compgen -A file)") ) && \
		return 0 
	    ;;
    esac

    # if doesn't exist, return opts
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -D -F _pkg pkg
