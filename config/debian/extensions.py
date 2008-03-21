import sys, os

# This function and its data should move into daklib/extensions.py
# or something.
replaced_funcs = {}
replace_funcs = {}
def replace_dak_function(module,name):
    def x(f):
        replace_funcs["%s:%s" % (module,name)] = f
    return x

@replace_dak_function("process-unchecked", "check_signed_by_key")
def check_signed_by_key():
    changes = dak_module.changes
    reject = dak_module.reject

    if changes["source"] == "dpkg":
        fpr = changes["fingerprint"]
        (uid, uid_name) = dak_module.lookup_uid_from_fingerprint(fpr)
        if fpr == "5906F687BD03ACAD0D8E602EFCF37657" or uid == "iwj":
            reject("Upload blocked due to hijack attempt 2008/03/19")

	    # NB: 1.15.0, 1.15.2 signed by this key targetted at unstable
	    #     have been made available in the wild, and should not be
	    #     blocked until Debian's dpkg has revved past those version
	    #     numbers

    replaced_funcs["check_signed_by_key"]()

def init(name):
    global replaced_funcs

    # This bit should be done automatically too
    replaced_funcs = {}
    for f,newfunc in replace_funcs.iteritems():
        m,f = f.split(":",1)
        if len(f) > 0 and m == name:
	    replaced_funcs[f] = dak_module.__dict__[f]
	    dak_module.__dict__[f] = newfunc

