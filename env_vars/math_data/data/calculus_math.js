const calculusMath = {
   index: 1,
   itemName: "Calculus",
   folderName: "Calculus",
   type: "General",
   entries: [
      {
         "title": "Calculus Description",
         "type": "NORMAL",
         "image": null,
         "data": [
            {
               "name": null,
               "value": "Calculus is "
            }
         ]
      },
      {
         "title": "Limits Definitions",
         "type": "NORMAL",
         "image": null,
         "data": [
            {
               "name": "Precise Definition",
               "value": "\n\tWe say limx→a f(x) = L\n\tif for every ε > 0\n\tthere is a δ > 0\n\tsuch that whenever 0 < |x − a| < δ\n\tthen |f(x) − L| < ε."
            },
            {
               "name": "\“Working\” Definition",
               "value": "\n\tWe say limx→a f(x) = L\n\tif we can make f(x) as close to L as we want by taking x sufficiently close to a (on either side of a)\n\twithout letting x = a."
            },
            {
               "name": "Right hand limit",
               "value": "\n\tlimx→a+ f(x) = L.\n\tThis has the same definition as the limit\n\texcept it requires x > a."
            },
            {
               "name": "Left hand limit",
               "value": "\n\tlimx→a− f(x) = L.\n\tThis has the same definition as the limit\n\texcept it requires x < a."
            },
            {
               "name": "Limit at Infinity",
               "value": "\n\tWe say limx→∞ f(x) = L\n\tif we can make f(x) as close to L as we want by taking x large enough and positive.\n\tThere is a similar definition for:\n\tlim x→− ∞ f(x) = L\n\texcept we require x large and negative."
            },
            {
               "name": "Infinite Limit",
               "value": "\n\tWe say limx→a f(x) = ∞\n\tif we can make f(x) arbitrarily large (and positive) by taking x sufficiently close to a (on either side of a)\n\twithout letting x = a.\n\tThere is a similar definition for:\n\tlimx→a f(x) = −∞\n\texcept we make f(x) arbitrarily large and negative"
            }
         ]
      },
      {
         "title": "Common Derivatives",
         "type": "NORMAL",
         "image": null,
         "data": [
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx} = 1"
                  }
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(sinx) = cosx"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(cosx) = -sinx"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(tanx) = sec^{2}x"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(secx) = secx * tanx"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(cscx) = -cscx * cotx"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(cotx) = -csc^{2}x"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(sin^{-1}x) = \\frac{1}{\\sqrt{1 - x^{2}}}"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(cos^{-1}x) = -\\frac{1}{\\sqrt{1 - x^{2}}}"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(tan^{-1}x) = \\frac{1}{\\sqrt{1 + x^{2}}}"
                  }                 
               ]
            },
            {
               "name": null,
               "values": [
                  {
                     "type": "MATH",
                     "value": "\\frac{d}{dx}(a^{x}) = a^{x}lna"
                  }                 
               ]
            }
         ]
      }            
   ]
};

export default calculusMath;