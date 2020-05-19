
int __GetClassId() {
    static int nextid = 1;
    return nextid++;
}

int __GetObjectId() {
    static int nextid = 1;
    return nextid++;
}

template<typename T>
string __GetClassName(T* clazz) {
    return typename(T);
}

template<typename T>
string GetClassName(T* obj) {
    return obj.GetClassName();
}

template<typename T>
int GetObjectId(T* obj) {
    return obj.GetObjectId();
}

template<typename T>
bool InstanceOf(void* obj) {
   T* casted_obj = dynamic_cast<T*>(obj);
   return casted_obj != NULL;
}

/*
Example implementation:

class CFaceRequestError : public CFace {
CLASSID
protected:
   CFaceRequestError() {}
public:
   bool GetSuccess(void* obj) {
      return false;
   }
   int GetError(void* obj) {
      return 0;
   }
};

template<typename T>
class CFaceRequestErrorT : public CFace {
public:
   bool GetSuccess(void* obj) {
      return ((T*)obj).success;
   }
   int GetError(void* obj) {
      return ((T*)obj).error;
   }
};
   
*/
#include "collections.mqh"
class CFace : public CObject {
public:
   virtual int GetClassId() {
        return -1;
   }
};

class CFaces {
   CMapPrimitiveObj<int,CFace> map;
public:
   virtual bool IsInitialized() {
      return map.Total() != 0;
   }
   virtual void AddFace(CFace* face) {
      map.Put(face.GetClassId(), face);
   }
   virtual CFace* GetFace(int face_class_id) {
      return map.Get(face_class_id);
   }
};

/*
   T should implement this method:
   
      virtual void GetFaces(CFace& faces[]);
      
   T subclass should override it like this:
   
      virtual CFaces* GetFaces() {
         static void* __faces[1];
         static CFaceRequestErrorT<CRequestModifyPending> f_request_error;
         
         if (__faces[0] == NULL) {
            __faces[0] = GetPointer(f_request_error);
         }
      }
      
   F should be subclass of CFace
   
   Usage example:
   
      CFaceRequestError* f_request_error = GetFace<CFaceRequestError,CRequest>(parameters);
      f_request_error.GetSuccess(parameters);
      f_request_error.GetError(parameters);
*/

template<typename F, typename T>
F* GetFace(T* obj) {
   CFaces* faces = obj.GetFaces();
   if (faces == NULL) return NULL;
   CFace* face = faces.GetFace(F::__GetClassId());
   return face;
}

#define CUSTOMNAME private:    string __customname;public:    void SetName(string name) {        __customname = name;    }    string GetName() {        return __customname;    }
/*
private:
    string __customname;
public:
    void SetName(string name) {
        __customname = name;
    }
    string GetName() {
        return __customname;
    }
*/

#define CLASSNAME public:    virtual string GetClassName() {        return __GetClassName(GetPointer(this));    }
/*
#define CLASSNAME
public:
    virtual string GetClassName() {
        return __GetClassName(this);
    }
*/

#define CLASSID public:    static int __GetClassId() {        static int id = -1;        if (id == -1) id = ::__GetClassId();        return id;    }public:    virtual int GetClassId() {        return this.__GetClassId();    }
/*
#define CLASSID
private:
    static int __GetClassId() {
        static int id = -1;
        if (id == -1) id = ::__GetClassId();
        return id;
    }
public:
    virtual int GetClassId() {
        return this.__GetClassId();
    }

*/

#define OBJECTID virtual int GetObjectId() {    static int id = -1;    if (id == -1) id = __GetObjectId();    return id;}

/*
#define OBJECTID
virtual int GetObjectId() {
    static int id = -1;
    if (id == -1) id = __GetObjectId();
    return id;
}

*/

#define OBJECTID_DELEGATE(DELEGATE) virtual int GetObjectId() {    static int id = -1;    if (id == -1) id = __GetObjectId();    return id;}

/*
#define OBJECTID_DELEGATE(DELEGATE)
virtual int GetObjectId() {
    return DELEGATE.GetObjectId();
}
*/

#define ABSTRACT_METHOD_WARNING Print("Calling abstract method in ",__FUNCTION__," class ",this.GetClassName());

/*
    Print("Calling abstract method in ",__FUNCTION__," class ",this.GetClassName());
*/