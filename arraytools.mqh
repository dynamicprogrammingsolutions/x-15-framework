template<typename T>
void ArrayResize(T& array[], const int newsize, const int increase_by) {
    int reserve = newsize;
    int excess = newsize%increase_by;
    if (excess > 0) reserve += increase_by;
    ArrayResize(array,newsize,reserve);
}

template<typename T>
int ArrayIncreaseByOne(T& array[], const int increase_by) {
    int newindex = ArraySize(array);
    ArrayResize(array,newindex+1,increase_by);
    return newindex;
}

template<typename T>
void ArrayAddItem(T& array[], T item, const int increase_by) {
    int newidx = ArrayIncreaseByOne(array,increase_by);
    array[newidx] = item;
}

template<typename T>
void ArrayAddItemAnywhere(T& array[], T item, const int increase_by) {
    int size = ArraySize(array);
    for (int i = 0; i != size; i++) {
        if (array[i] == NULL) {
            array[i] = item;
            return;
        }
    }
    ArrayAddItem(array,item,increase_by);
}

template<typename T>
void ArrayRemoveItem(T& array[], const int idx, const int increase_by) {
    int size = ArraySize(array);
    array[idx] = NULL;
    for (int i = idx+1; i != size; i++) {
        array[i-1] = array[i];
    }
    ArrayResize(array,size-1,increase_by);
}
