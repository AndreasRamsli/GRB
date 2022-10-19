#functions for handlig log files from Xspec

def get_cellInput(l):
    cell_input = ''
    for x in l:
        if x == '+/-':
            cell_input += ' ' + x + ' '
        else:
            try:
                float(x)
                cell_input += str(np.round(float(x),3))
            except ValueError:
                continue
    return(cell_input)




def get_datagroups(log_fname=None):
    if type(log_fname) != str:
        return print('log_fname must be str')
    else:
        with open(log_fname,'r') as f:
            
            logLines = f.readlines()
            #looking for this line: #Model constant<1>*cflux<2>*ngrbep<3> Source No.: 1   Active/On
            for l in logLines:
                if l == '#Model constant<1>*cflux<2>*ngrbep<3> Source No.: 1  Active/On':
                    print(l)

            for i,l in enumerate(logLines):
                if l == '#Current model list:\n':
                    print('model list start at index: ', i)
                    modList = logLines[i:]
                    break
                    
    clean_modList = []
    for l in modList:
        l = l.replace('\n','')
        l = l.replace('#','')
        clean_modList.append(l)

    keys = {}
    for i,l in enumerate(clean_modList):
        if 'Data group:' in l:
            key = l.strip()
            keys[key] = i
    startingIndecies = np.fromiter(keys.values(), dtype=int)
    n_dataGroups = len(startingIndecies)

    if np.all(np.diff(startingIndecies)) == True:
        size_dataGroup = np.diff(np.fromiter(keys.values(), dtype=int))[0]
    else:
        print('varying length of datagroups')
        
    print('startingIndecies,n_dataGroups: ',startingIndecies,n_dataGroups)
    spec_data = {}
    for key,value in keys.items():
        newTargetModel = []
        targetModel = clean_modList[value+1:value+size_dataGroup]
        for par in targetModel:
            newpar = par.strip()
            newpar = newpar.split()
            del newpar[1]
            newTargetModel.append(newpar)
        spec_data[key] = newTargetModel
        
    for l in spec_data.values(): #deleting 'constant' keyword
        del l[0][0]
        
    v = list(spec_data.values())
    #TODO: replace  4 with 'n datagroups' & 9 with 
    for i in range(0,4): #replace n-1 -diff(n_datagroups)
        for j in range(0,9):
            del v[i][j][0]

    for i in range(0,4):#replace 4
        key = list(spec_data.keys())[i]
        clean_dict[key] = v[i]
        
    df = pd.DataFrame(data = clean_dict).T
    for i in range(0,4): #replace 4
        for j in range(0,9):#replace 9
            #print(list(clean_dict.values())[i][j])
            df.values[i][j] = (get_cellInput(list(clean_dict.values())[0][i]))
            
    return df





def df_toLatex(df=None):
    import pandas as pd
    
    if type(df) != pd.core.frame.DataFrame:
        return print('input df not correct format')
    else:
        print(df.T.style.to_latex(position_float='centering',position='h!',hrules=True,multirow_align='c'))