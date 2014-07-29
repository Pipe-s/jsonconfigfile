declare -A customPackages=(
 [singleton3]='git+https://github.com/pipe-s/Singleton.git#egg=singleton3'
)

overloadForCustomPackage()
{
		{
		if $(cat -s ~/.pip/pip.conf | grep localhost &> /dev/null); then
				echo "Here"
				PACKAGE=$1
				return 0			
		fi
		if [[ -n "${customPackages[$1]}" ]]; then
			PACKAGE=${customPackages[$1]}
			return 0
		fi
		echo "here1"
		PACKAGE=$1
		} &> /dev/null
}

/bin/rm -f .pipPackageList
pip3 freeze > .pipPackageList

for P in pytest coverage radon singleton3
do
        /usr/bin/python2 find_package.py --package $P .pipPackageList
        case $? in
        1)
                echo "Python package $P not found, installing..."
        		overloadForCustomPackage $P
		    	y="pip3 install $PACKAGE"
        		$y
                ;;
        2)
                echo "Python package $P needs upgrade, upgrading..."
        		overloadForCustomPackage $P
        		y="pip3 install --upgrade $PACKAGE"
        		$y
                ;;
        esac
done

/bin/rm -f .pipPackageList
