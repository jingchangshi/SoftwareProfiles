import numpy as np
from matplotlib import use
use('Agg')
import matplotlib.pyplot as plt
plt.style.use('sjc')
fig=plt.figure()
ax=fig.gca()
x=np.linspace(-1,1,201)
y=np.sin(2.0*np.pi*x)
ax.plot(x,y,'o-',label=r"$sin(2 \pi x)$")
ax.plot(x,-y,'--',label=r"$-sin(2 \pi x)$")
ax.plot(x,2*y,'-.',label=r"$2sin(2 \pi x)$")
ax.plot(x,3*y,':',label=r"$3sin(2 \pi x)$")
ax.set_xlabel("x")
ax.set_ylabel(r"$y$")
import matplotlib.font_manager as fm
# ax.set_title("Sin function "+r"$sin$",fontproperties=prop)
ax.set_title("Sin function "+r"$sin$")
ax.text(0,0,"abc $10^{-5}$")
ax.legend()
plt.tight_layout()
plt.savefig("test_plot_style.png")
