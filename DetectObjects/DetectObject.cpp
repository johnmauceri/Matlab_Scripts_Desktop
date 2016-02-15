//***********************************************************************
//          X p a n d                      C o n t o u r
//                D e m o n s t r a t i o n
//
//                                Copyright (c) John Coulthard, 2002
//***********************************************************************
#include <stdlib.h>
#include <iostream>
#include "surfgrid.h"
#include "contour.h" 
#include <vector>
#include <fstream>
#include <ctime>
#include <math.h>
#include <algorithm>
#include <mex.h>
#include "matrix.h"

using namespace std;

static vector<float> allcontours;
static vector<float> XLocVec;
static vector<float> YLocVec;
static float contourVal;


class Row
	{ private: float* _p;
	  public: Row( float* p )                   { _p = p; }
    	  float& operator[](int col)        { return _p[col]; }
	};
class Matrix
	{ private: float* _p;
    	  int _cols;
	  public:
    	  Matrix( int rows, int cols )  { _cols=cols; _p = (float*) mxMalloc(rows*cols*sizeof(float) ); }
    	  Row operator[](int row)       { return _p + row*_cols; }
	};

double ContourElim(float scale_factor, double bscale, int nx, int ny, Matrix z, int N_Levels, float* cLevels,    		\
		   double max_contour_length, double max_contours, float* contour_data, float* number_contours,			\
		   float* contour_value, double* contour_length, double* contour_x_begin, double* contour_x_end, 		\
		   double* contour_y_begin, double* contour_y_end, int &nconmax);

//***********************************************************************
//           D o   L i n e    T o
//
// Called by Contour to trace contour lines.
//************************************************************************
void DoLineTo( float x, float y, int draw )
{
    
    if (draw==1)
    {
        XLocVec.push_back(x);
        YLocVec.push_back(y);
    }
    else {
        if (XLocVec.size()!=0)
        {
            allcontours.push_back((float) XLocVec.size());
            allcontours.push_back(-1);
            allcontours.push_back(-1);
            allcontours.push_back(-1);
            allcontours.push_back(-1);
            allcontours.push_back(contourVal);
            allcontours.insert(allcontours.end(), XLocVec.begin(), XLocVec.end());
            allcontours.insert(allcontours.end(), YLocVec.begin(), YLocVec.end());
            
            XLocVec.clear();
            YLocVec.clear();
        }
        XLocVec.push_back(x);
        YLocVec.push_back(y);
    }
};


/* Object-detection algorithm - HXV, Curemetrix, Inc - October 2015
   Detect metal clamps, clips, breast implants, and other hard objects.
   This algorithm inspects the "saturated-fraction" of each contour and the ratio of standard deviation/mean of its 
   intensity to determine of the contour circumscribes  a hard object.
   This algorithm works well for close contours, AND for open contours for which the two terminal points lie on the same
   edge of the image, i.e, left boundary, right boundary, top boundary, or bottom boundary. This algorithm does not work 
   reliably and will need to be modified if the two terminal points (of an open contour) lie on wo different edges
   of the image */

 void DetectObject(float scale_factor, int xoffset, int yoffset, int nx, int ny, Matrix z, int N_Levels, float* cLevels,         \
		   double bscale, double PixelArea,double max_contour_length, double max_contours, float* contour_data, 	 \
		   float* number_contours, float* contour_value, double* contour_length, double* contour_x_begin, 		 \
		   double* contour_x_end, double* contour_y_begin, double* contour_y_end)
{
	unsigned long int size = 10000*6000;
	int i,j;
	unsigned long int index,index_total,index_total_begin;
    	double xmean, ymean, dx, dy, A, Axc, Ayc, P, xc, yc, x0, y0, x, y, dl, Imean, I2mean,Istd;
    	unsigned long int x_begin,y_begin,contour_counter,x_end,y_end,open_contours;
	int contour_x_LL,contour_x_UR,contour_y_LL,contour_y_UR;
	double x_LL,x_UR,y_LL,y_UR,max_intensity,BrightnessAvg,Lscale;
  	float dotproduct,vec_1_x,vec_1_y,saturated_fraction,saturated_count,total_count;
  	float cross_product_12, cross_product_23, cross_product_31,xg,yg;
	int iv,InteriorFlag,nx_skip,ny_skip,nv_skip,saturated_contours,NLocalMax;
  	float *ddx;
  	float *ddy;
  	ddx = (float *) mxMalloc(pow((double) 2,(double) 20)*sizeof(float));
  	ddy = (float *) mxMalloc(pow((double) 2,(double) 20)*sizeof(float));

        SurfaceGrid Result(nx,ny);         // Define the grid to be generated.
        
        // Load up our input array with DICOM data points.
        for(int i=0;i<nx;i++) { for (int j=0; j<ny; j++) { Result.zset(i, j, z[i][j]); } }
        
        // Initialize the grid x and y coordinates
        for( i = 0; i < nx; i++ ) Result.xset( i, float(i+xoffset)/scale_factor + 1 );
        for( j = 0; j < ny; j++ ) Result.yset( j, float(j+yoffset)/scale_factor + 1 );
    
    time_t t_base_start_t, t_base_end_t;

    t_base_start_t = time(0);
    index_total = 0;

    for (int contourLevelCnt=0; contourLevelCnt<N_Levels; contourLevelCnt++)
    {
        time_t tstart, tend;
        time(&tstart);
        contourVal = cLevels[N_Levels - 1 - contourLevelCnt]; /* Reverse the order of contours */
        //contourVal = cLevels[contourLevelCnt];
        allcontours.clear();
        XLocVec.clear();
        YLocVec.clear();
        Contour( Result , contourVal ) ;
        
        DoLineTo( -2, -2, -1);
        
        time(&tend);
        
	index_total_begin = index_total;
        for (vector<float>::const_iterator i = allcontours.begin(); i != allcontours.end(); ++i)
            { 
	      contour_data[index_total]   = *i; 
	      index_total++           ;
	    }
    }

    contour_data[index_total] = -2;
    index_total++;
    contour_data[index_total] = -2;
    index_total++;
    contour_data[index_total] = -2;
    index_total++;
    contour_data[index_total] = -2;
    index_total++;
    contour_data[index_total] = -2;
    index_total++;
    contour_data[index_total] = -2;
    index_total++;

    t_base_end_t = time(0);

    //Count number of contours and perform administrative tasks

    t_base_start_t = time(0);

    float a[6];
    index = 0;
    number_contours[0] = 0;
    contour_counter    = 0;
    saturated_contours = 0;
    for (i = 0; i < 6; i++) { a[i] = contour_data[index+i];}
    index  = 6;
    while (a[0] != -2)
	{
		x_begin = index;
		y_begin = index + (unsigned long int) a[0];
		x_end   = y_begin - 1;
		y_end   = x_end + (unsigned long int) a[0];

               	//Calculate area, centroid, and perimeter
		A        = 0.;
		Axc      = 0.;
		Ayc      = 0.;
		P        = 0.;
		xc       = 0.;
		yc       = 0.;
		xmean    = 0.;
		ymean    = 0.;
    		for (i = 0; i < (int) a[0] ; i++) 
			{ 
	 			xmean = xmean + (double) contour_data[x_begin + i];
	 			ymean = ymean + (double) contour_data[y_begin + i];
			}
		xmean = xmean / double(a[0]);
		ymean = ymean / double(a[0]);


		x0 = (double) contour_data[x_begin + (unsigned long int) a[0] - 1] - xmean;
		y0 = (double) contour_data[y_begin + (unsigned long int) a[0] - 1] - ymean;

		x_LL   = 10000;
		x_UR   = 1;
		y_LL   = 10000;
		y_UR   = 1;

		//Check for open contours (i.e., contours that intersect the domain boundaries)
		if (contour_data[x_begin] == float(xoffset)/scale_factor + 1 || contour_data[x_end] == float(nx+xoffset)/scale_factor || \
		    contour_data[y_begin] == float(yoffset)/scale_factor + 1 || contour_data[y_end] == float(ny+yoffset)/scale_factor || \
		    contour_data[x_begin] != contour_data[x_end] ||  contour_data[y_begin] != contour_data[y_end] )
			{
				open_contours = 1; //Open contour
			}
		else
			{
				open_contours == 0; //Close contour
			}


     		for (i = 0; i < (int) a[0] ; i++) 
	 		{ 
		 		x   = contour_data[x_begin + i] - xmean;
		 		y   = contour_data[y_begin + i] - ymean;
		 		dx  = - x + x0;
		 		dy  = - y + y0;
				dl       = sqrt(dx*dx + dy*dy);
		 		A   = A + y*dx - x*dy;
 		 		Axc = Axc + 6*x*y*dx - 3*x*x*dy + 3*y*dx*dx + dx*dx*dy;
		 		Ayc = Ayc + 3*y*y*dx - 6*x*y*dy - 3*x*dy*dy - dx*dy*dy;
		 		P   = P + dl;
		 		x0  = x;
		 		y0  = y;
				x_LL = min(x_LL,(double) contour_data[x_begin+i]);
				x_UR = max(x_UR,(double) contour_data[x_begin+i]);
				y_LL = min(y_LL,(double) contour_data[y_begin+i]);
				y_UR = max(y_UR,(double) contour_data[y_begin+i]);
	 		}
		x_LL = (x_LL - 1)*scale_factor; //Scaling to account for image resizing
		x_UR = (x_UR - 1)*scale_factor; //Scaling to account for image resizing
		y_LL = (y_LL - 1)*scale_factor; //Scaling to account for image resizing
		y_UR = (y_UR - 1)*scale_factor; //Scaling to account for image resizing
		contour_x_LL = (int) floor(x_LL); //x-index of lower-left  corner of contour
		contour_x_UR = (int) floor(x_UR); //x-index of upper-right corner of contour
		contour_y_LL = (int) floor(y_LL); //y-index of lower-left  corner of contour
		contour_y_UR = (int) floor(y_UR); //y-index of upper-right corner of contour

		A   = A  / 2. ;
		Axc = Axc/ 12. ;
		Ayc = Ayc/ 12. ;

		if (A != 0) 
 			{
 				if (A < 0)
	 				{
		 				A   = -A;
		 				Axc = -Axc;
		 				Ayc = -Ayc;
	 				}
 				xc = Axc / A;
 				yc = Ayc / A;
 				for (i = 0; i < (int) a[0] ; i++) 
	 				{
		 				x   = contour_data[x_begin + i] - xmean;
		 				y   = contour_data[y_begin + i] - ymean;
	 				}
 				xc = xc + xmean;
 				yc = yc + ymean;
				
				/*Check to see if grid point (xg,yg) is interior to the contour and find maximum intensity within contour */
				nx_skip = 1+(int) floor((contour_x_UR - contour_x_LL + 1)/20.);
				ny_skip = 1+(int) floor((contour_y_UR - contour_y_LL + 1)/20.);
				saturated_count = 0;
				total_count     = 0;
				Imean           = 0;
				I2mean          = 0;
    				for (i = contour_x_LL; i < contour_x_UR ; i=i+nx_skip) 
					{
       						xg = float(i+xoffset)/scale_factor + 1;
    						for (j = contour_y_LL; j < contour_y_UR ; j=j+ny_skip) 
							{
       								yg = float(j+yoffset)/scale_factor + 1;

        							vec_1_x = xc - xg;
                						vec_1_y = yc - yg;

								nv_skip = 1+(int) floor(a[0]/100.);
								dotproduct = 0;
  								for ( iv = 0; iv < (int) a[0]; iv=iv+nv_skip)
									{
										ddx[iv]     = contour_data[x_begin + iv] - xg;
										ddy[iv]     = contour_data[y_begin + iv] - yg;
           									dotproduct = min(dotproduct,vec_1_x*ddx[iv]+vec_1_y*ddy[iv]);
									}

								if (dotproduct < 0)
									{
										iv           = 0;
										InteriorFlag = 0;
  										while ( InteriorFlag == 0 && iv < (int) a[0]-nv_skip)
											{
                    										//Compute cross products
                   	 									cross_product_12 =  vec_1_x  *ddy[iv]   \
												  	  	  - vec_1_y  *ddx[iv];
                     										cross_product_23 =  ddx[iv]  *ddy[iv+nv_skip] \
														  - ddy[iv]  *ddx[iv+nv_skip];
                     										cross_product_31 =  ddx[iv+nv_skip]*vec_1_y   \
														  - ddy[iv+nv_skip]*vec_1_x;
                     										if ((cross_product_12 > 0 && cross_product_23 > 0 && cross_product_31 > 0) || \
                        			    						(cross_product_12 < 0 && cross_product_23 < 0 && cross_product_31 < 0)     ) {InteriorFlag = 1;}
												iv = iv + nv_skip;
											}
									}
								else
									{
										InteriorFlag = 0;
									}

								if (InteriorFlag == 1)
									{
							 			if ( (z[i][j] > a[5] && open_contours == 1) || open_contours == 0 )
											{
												total_count++;
												Imean  = Imean  + z[i][j];
												I2mean = I2mean + z[i][j]*z[i][j];
											}
							 			if (z[i][j] >= 0.99*bscale)
											{
												saturated_count++;
											}
									}
							}
					}


				total_count = max((double) 1, (double) total_count);
				saturated_fraction = saturated_count / total_count;
				Imean  = Imean  / total_count;
				I2mean = I2mean / total_count;
				Istd   = sqrt(I2mean - Imean*Imean);
				// Detect saturated contours - metal clamps, clips, etc.

				if ((saturated_fraction > 0.99 || (Istd/Imean < 0.02 && Imean > 0.95*bscale)) && A*PixelArea > 100)
					{
						contour_value  [(unsigned long int) number_contours[0]] = a[5];                           // contour level
						contour_length [(unsigned long int) number_contours[0]] = a[0];                           // number of points on contour
						//MATLAB index begins at 1, hence the offset!
						contour_x_begin[(unsigned long int) number_contours[0]] = index + 1;                      //begin index for x coordinates
						contour_x_end  [(unsigned long int) number_contours[0]] = index + 1 +   double(a[0]) - 1; //end   index for x coordinates
						contour_y_begin[(unsigned long int) number_contours[0]] = index + 1 +   double(a[0]);     //begin index for y coordinates
						contour_y_end  [(unsigned long int) number_contours[0]] = index + 1 + 2*double(a[0]) - 1; //end   index for y coordinates
						number_contours[0]++;
			 		}
			}

		//Increment contour counters
		contour_counter++;
		index = index + 2*(int) a[0];
    		for (i = 0; i < 6; i++) { a[i] = contour_data[index+i];}
		index = index + 6;
	 } //End while loop

    t_base_end_t = time(0);
    mexPrintf("Time spent in object detection: %g seconds\n",difftime(t_base_end_t, t_base_start_t));
    mexPrintf("\n");

    mexPrintf("Number of objects detected = %i\n",(int) number_contours[0] );
    mexPrintf("End of C++ DetectObject\n");

    mexPrintf("\n");
    mxFree(ddx);
    mxFree(ddy);
    return;
}

 double ContourElim(float scale_factor, double bscale, int nx, int ny, Matrix z, int N_Levels, float* cLevels,  		\
		    double max_contour_length, double max_contours, float* contour_data, float*number_contours, 		\
		    float* contour_value, double* contour_length, double* contour_x_begin, double* contour_x_end, 		\
		    double* contour_y_begin, double* contour_y_end, int &nconmax)
{
    time_t t_base_start_t, t_base_end_t;

    t_base_start_t = time(0);

    double x,y;
    unsigned long int x_begin,y_begin;

    int ncon = 0;
    double contour_max_mem = 0;

    for ( int i = 0; i < (int) number_contours[0]; i++)
	{
            	if (ncon < nconmax)
			{
				contour_max_mem = contour_max_mem + 6 + 2* contour_length[i]; 
				ncon = ncon + 1;
			}
	}


    t_base_end_t = time(0);
    nconmax      = ncon;
    return contour_max_mem;
}

void mexFunction(
		 int          nlhs,
		 mxArray       *plhs[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{

  /* Check for proper number of arguments */

  if (nrhs != 5 && nrhs != 9) {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin", 
            "DetectObject requires either 4 or 8 input arguments.");
  } else if (nlhs != 8) {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
            "DetectObject requires exactly 8 output arguments.");
  }

  /* get input data */
  float      scale_factor;
  double     bscale, PixelArea;
  float      *data;
  float      *cLevels;
  int        nx,ny,N_Levels,nx_LL,nx_UR,ny_LL,ny_UR;
  if (nrhs == 5)
	{
		mexPrintf("Lower-left and upper-right corners not specified - entire image is processed.\n");
  		scale_factor = (float ) mxGetScalar(prhs[0]);
  		nx           = (int )   mxGetM(prhs[1]);
  		ny           = (int )   mxGetN(prhs[1]);
  		data         = (float*) mxGetData(prhs[1]);
  		N_Levels     = (int )  mxGetM(prhs[2]) * (int ) mxGetN(prhs[2]);
  		cLevels      = (float*) mxGetData(prhs[2]);
  		bscale       = (double) mxGetScalar(prhs[3]);
  		PixelArea    = (double) mxGetScalar(prhs[4]);
		nx_LL        = 0;
		ny_LL        = 0;
		nx_UR        = nx - 1;
		ny_UR        = ny - 1;
	}
  if (nrhs == 9)
	{
  		nx_LL        = (int   ) mxGetScalar(prhs[0]) - 1; //MATLAB index starts at 1 while C++ index starts at 0;
  		nx_UR        = (int   ) mxGetScalar(prhs[1]) - 1; //MATLAB index starts at 1 while C++ index starts at 0;
  		ny_LL        = (int   ) mxGetScalar(prhs[2]) - 1; //MATLAB index starts at 1 while C++ index starts at 0;
  		ny_UR        = (int   ) mxGetScalar(prhs[3]) - 1; //MATLAB index starts at 1 while C++ index starts at 0;
  		scale_factor = (float ) mxGetScalar(prhs[4]);
  		nx           = (int )   mxGetM(prhs[5]);
  		ny           = (int )   mxGetN(prhs[5]);
  		data         = (float*) mxGetData(prhs[5]);
  		N_Levels     = (int )  mxGetM(prhs[6]) * (int ) mxGetN(prhs[6]);
  		cLevels      = (float*) mxGetData(prhs[6]);
  		bscale       = (double) mxGetScalar(prhs[7]);
  		PixelArea    = (double) mxGetScalar(prhs[8]);
		mexPrintf("Lower-left  corner = (%i,%i)\n",nx_LL,ny_LL);
		mexPrintf("Upper-right corner = (%i,%i)\n",nx_UR,ny_UR);
	}

  int index = 0;
  mexPrintf("nx        = %i\n",nx      );
  mexPrintf("ny        = %i\n",ny      );

  /*create temporary (internal) matrices*/
  double max_contour_length = pow(double(2),double(29));
  double max_contours       = pow(double(2),double(24));
  float      *contour_data;
  float      *number_contours;
  float      *contour_value;
  double     *contour_length;
  double     *contour_x_begin;
  double     *contour_x_end;
  double     *contour_y_begin;
  double     *contour_y_end;
  contour_data           = (float *) mxMalloc(max_contour_length*sizeof(float));
  number_contours        = (float *) mxMalloc(sizeof(float));
  contour_value          = (float  *) mxMalloc(max_contours*sizeof(float ));
  contour_length         = (double *) mxMalloc(max_contours*sizeof(double));
  contour_x_begin        = (double *) mxMalloc(max_contours*sizeof(double));
  contour_x_end          = (double *) mxMalloc(max_contours*sizeof(double));
  contour_y_begin        = (double *) mxMalloc(max_contours*sizeof(double));
  contour_y_end          = (double *) mxMalloc(max_contours*sizeof(double));

  int nconmax;
  nconmax = 50000; //ORIGINAL IDL-VER2.0-JUNE1
  double contour_max_mem;
  int    ncon;

  //Extract full 2D array from 1D array
	Matrix z(nx,ny);

	int i,j;
	index   = 0;
	/* i = First Dimension (Vertical); j = Second Dimension (Horizontal) */
 	for( j = 0; j < ny; j++ ) 
		{
  			for( i = 0; i < nx; i++ ) 
				{ 
					z[i][j] = data[index];
					index++;
				};
		};

  //Generate contours
  if (nrhs == 5)
	{
  		DetectObject(scale_factor,nx_LL,ny_LL,nx,ny,z,N_Levels,cLevels,bscale,PixelArea,			\
	     	 	   max_contour_length,max_contours,							  	\
	     		   contour_data,number_contours,contour_value, 					  	  	\
             		   contour_length,contour_x_begin,contour_x_end,contour_y_begin,contour_y_end);
	}
  if (nrhs == 9)
	{
  		//Extract patch from full 2D array
		int delta_x = nx_UR - nx_LL + 1;
		int delta_y = ny_UR - ny_LL + 1;
		Matrix Patch(delta_x,delta_y),dPdx(delta_x,delta_y),dPdy(delta_x,delta_y);
 		for( j = 0; j < delta_y; j++ ) 
			{
  				for( i = 0; i < delta_x; i++ ) 
					{ 
						Patch[i][j] = z   [i+nx_LL][j+ny_LL];
					};
			};
  		DetectObject(scale_factor,nx_LL,ny_LL,delta_x,delta_y,Patch,N_Levels,cLevels,bscale,PixelArea, 			  \
	     	 	   max_contour_length,max_contours,							  		  \
	     		   contour_data,number_contours,contour_value, 					  	  		  \
             		   contour_length,contour_x_begin,contour_x_end,contour_y_begin,contour_y_end);
	}

  //Eliminate contours based on various metrics
  contour_max_mem = ContourElim(scale_factor,bscale,nx,ny,z,N_Levels,cLevels,                      	      	      \
	      			max_contour_length,max_contours,contour_data,number_contours,contour_value,	      \
              			contour_length,contour_x_begin,contour_x_end,contour_y_begin,contour_y_end,nconmax);

  /* create the output matrices */
  float      *contour_data_EXT;
  float      *number_contours_EXT;
  float      *contour_value_EXT;
  double     *contour_length_EXT;
  double     *contour_x_begin_EXT;
  double     *contour_x_end_EXT;
  double     *contour_y_begin_EXT;
  double     *contour_y_end_EXT;
  plhs[0 ] = mxCreateNumericMatrix((mwSize) contour_max_mem,1,mxSINGLE_CLASS,mxREAL);
  plhs[1 ] = mxCreateNumericMatrix(1,1,mxSINGLE_CLASS,mxREAL);
  plhs[2 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxSINGLE_CLASS,mxREAL);
  plhs[3 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxDOUBLE_CLASS,mxREAL);
  plhs[4 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxDOUBLE_CLASS,mxREAL);
  plhs[5 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxDOUBLE_CLASS,mxREAL);
  plhs[6 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxDOUBLE_CLASS,mxREAL);
  plhs[7 ] = mxCreateNumericMatrix((mwSize) nconmax,1,mxDOUBLE_CLASS,mxREAL);

  contour_data_EXT           = (float*)  mxGetData(plhs[0 ]);
  number_contours_EXT        = (float*)  mxGetData(plhs[1 ]);
  contour_value_EXT          = (float*)  mxGetData(plhs[2 ]);
  contour_length_EXT         = (double*) mxGetData(plhs[3 ]);
  contour_x_begin_EXT        = (double*) mxGetData(plhs[4 ]);
  contour_x_end_EXT          = (double*) mxGetData(plhs[5 ]);
  contour_y_begin_EXT        = (double*) mxGetData(plhs[6 ]);
  contour_y_end_EXT          = (double*) mxGetData(plhs[7 ]);

  unsigned long int contour_counter = 0, index_total = 0;
  number_contours_EXT[0]  = 0;
  for ( int i = 0; i < (int) number_contours[0]; i++)
	{
  		contour_value_EXT          [contour_counter] = contour_value          [i];
  		contour_length_EXT         [contour_counter] = contour_length         [i];
  		contour_x_begin_EXT        [contour_counter] = (double) index_total + 6 + 1;
  		contour_x_end_EXT          [contour_counter] = contour_x_begin_EXT[contour_counter] + contour_length[i] - 1;
  		contour_y_begin_EXT        [contour_counter] = contour_x_end_EXT  [contour_counter] + 1;
  		contour_y_end_EXT          [contour_counter] = contour_y_begin_EXT[contour_counter] + contour_length[i] - 1;
		for (j = 0; j < 6 + 2*(unsigned long int) contour_length[i]; j++) 
			{
				contour_data_EXT[-6 + (unsigned long int) contour_x_begin_EXT[contour_counter] - 1 + j] = \
				contour_data    [-6 + (unsigned long int) contour_x_begin    [i]               - 1 + j];
			}
		index_total = index_total + 6 + 2*(unsigned long int) contour_length[i];
  		contour_counter++;

	}
  number_contours_EXT[0] = contour_counter;
  //Free up memory
  mxFree(number_contours       );
  mxFree(contour_value         );
  mxFree(contour_length        );
  mxFree(contour_data          );
  mxFree(contour_x_begin       );
  mxFree(contour_x_end         );
  mxFree(contour_y_begin       );
  mxFree(contour_y_end         );
  return;
}



//****************************************************************
//                        S u r f a c e   G r i d
//
//                 Copyright (c) 1993 - 2002 by W. John Coulthard
//
//    This source code is mxFree software; you can redistribute it and/or
//    modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//*****************************************************************

//#include "surfgrid.h"
#define max(a,b) (((a)>(b))?(a):(b))
#define min(a,b) (((a)<(b))?(a):(b))

SurfaceGrid::SurfaceGrid( const int i, const int j )
{
  int k;
  nx=i;
  ny=j;
  zgrid = new float[(long)nx*(long)ny];
  xvect = new float[nx];
  yvect = new float[ny];
  for( k = 0; k<nx; k++ ) xvect[k] = (float) k;
  for( k = 0; k<ny; k++ ) yvect[k] = (float) k;
}

void  SurfaceGrid::zset( const int i, const int j, const float a )
{
  int offset = (long)j*nx + (long)i;
  zgrid[offset] = a ;
}

void  SurfaceGrid::xset( const int i, const float a )
{
  xvect[i] = a ;
}

void  SurfaceGrid::yset( const int i, const float a )
{
  yvect[i] = a ;
}


//***************************************************************
//                     Contour plotting of a grid.
//                               
//               Copyright (c) 1993 - 2002 by John Coulthard
//
//    This source code is mxFree software; you can redistribute it and/or
//    modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//************************************************************************
//
//   This code is a transcription of a FORTRAN IV subroutine called
//   CNTOUR that I wrote in the late 60's. (that is why it contains
//   goto's). The last known bug was removed from CNTOUR in 1972 and I
//   did not wish to change the structure of such a stable piece of code.
//
//   The source code for CNTOUR was published in the SHARE user's group
//   library. The code was widely distributed and heavily used.
//
//***************************************************************
// Requires a simple class defined in surfgrid.h and surfgrid.cpp to
// supply the grid. 
//

//#include "surfgrid.h"  // The simple class mentioned above.
#include <memory.h>       // For memset function in switches

// Forward declare functions in switches.cpp.
void SwitchClear(int i, int j);
int SwitchGet  (int i, int j);
int SwitchSet  (int i, int j);


static int XReferencePoint,  // We are contouring between a
           YReferencePoint,  //    Reference point and a
           XSubPoint,        //    Sub point. These are used to scan
	        YSubPoint,        //    the grid and mark beginings of lines.
           NumberOfX,        // Number of X and Y grid lines.
	        NumberOfY,
           Drawing;

static float ContourValue;    // Value we are contouring.

// Forward declare functions in contour.cpp
static void TraceContour( SurfaceGrid &Zgrid );
static void Interpolate( float, float, float, float, float, float);

// DoLineTo must be supplied by the calling routine. 
void DoLineTo( float x, float y, int drawtype );

//****************************************************************
//                    C o n t o u r
//****************************************************************

void Contour( SurfaceGrid &Zgrid, float TourValue )

// This function conducts a search of all of the elements of the
// rectangular grid looking for existence of the contour line
// represented by TourValue.

// Once the value is found function TraceContour is called to
// actually trace the contour through the grid. It ultimately
// calls function DoLineTo which must be supplied to actually
// draw the line.

// An array of switches is maintained to flag whether a given
// grid location has been already contoured or not (to prevent
// tracing a contour line more than once.

{
   NumberOfX = Zgrid.xsize();
   NumberOfY = Zgrid.ysize();
   SwitchClear(NumberOfX, NumberOfY);
   ContourValue = TourValue;

// Search for a bottom edge contour
   
   YReferencePoint = 0;
   YSubPoint       = 0;

   for( XReferencePoint = 1; XReferencePoint<NumberOfX; XReferencePoint++ )
   {
     if( Zgrid.z(XReferencePoint,0) <= ContourValue ) continue;
     XSubPoint = XReferencePoint - 1;
     if( Zgrid.z(XSubPoint,0) > ContourValue)   continue;
     TraceContour( Zgrid );
   }

// Search for a right edge contour
   
   XReferencePoint = NumberOfX - 1;
   XSubPoint       = XReferencePoint;

   for( YReferencePoint =1; YReferencePoint<NumberOfY; YReferencePoint++)
   {
    if( Zgrid.z(NumberOfX -1, YReferencePoint) <= ContourValue) continue;
    YSubPoint = YReferencePoint -1;
    if (Zgrid.z(NumberOfX -1, YSubPoint) > ContourValue) continue;
    TraceContour( Zgrid );
   }

// Search the top edge.
    
   YReferencePoint = NumberOfY-1;
   YSubPoint       = YReferencePoint;

   for( XReferencePoint = NumberOfX-2; XReferencePoint>=0; XReferencePoint--)
   {
    if( Zgrid.z( XReferencePoint,NumberOfY-1) <= ContourValue) continue;
    XSubPoint = XReferencePoint + 1;
    if( Zgrid.z( XSubPoint,      NumberOfY-1) >  ContourValue) continue;
    
    TraceContour( Zgrid );
    
   }

// Search the left edge
   
   XReferencePoint = 0;
   XSubPoint       = 0;

   for ( YReferencePoint = NumberOfY-2; YReferencePoint>=0;YReferencePoint--)
   {
    if( Zgrid.z( 0, YReferencePoint) <= ContourValue ) continue;
    YSubPoint = YReferencePoint + 1;
    if( Zgrid.z( 0, YSubPoint) > ContourValue ) continue;
    TraceContour( Zgrid );
   }

// Search the interior of the array
   
   for( YReferencePoint = 1; YReferencePoint<NumberOfY-1; YReferencePoint++)
   {
    for( XReferencePoint =1; XReferencePoint<NumberOfX;   XReferencePoint++)
    {
     XSubPoint = XReferencePoint-1;
     if( Zgrid.z(XReferencePoint,YReferencePoint)<=ContourValue) continue;
     if( Zgrid.z(XSubPoint,      YReferencePoint)> ContourValue) continue;
     if( SwitchGet(XReferencePoint,YReferencePoint)) continue;

     YSubPoint = YReferencePoint;
     TraceContour( Zgrid );
    }
   }
 SwitchClear( 0, 0 ); // All done! delete memory for switches.
}

//*******************************************************************
//                  T r a c e   C o n t o u r
//********************************************************************

static void TraceContour( SurfaceGrid &Zgrid )
{
  static const int XLookupTable[9] = {  0, 1, 1,  0, 9, 0, -1, -1, 0};
  static const int YLookupTable[9] = { -1, 0, 0, -1, 9, 1,  0,  0, 1};
  static const int DiagonalTest[9] = {  0, 1, 0,  1, 0, 1,  0,  1, 0};

  static int XTracePoint,
             YTracePoint,
             XTraceSubPoint,
             YTraceSubPoint;
	       
  static float XMidPoint,
               YMidPoint,
               ZMidPoint;

  static int Locate,
             XNext,
             YNext,
             XMidNext,
             YMidNext;

  XTracePoint = XReferencePoint;
  YTracePoint = YReferencePoint;
  XTraceSubPoint = XSubPoint;
  YTraceSubPoint = YSubPoint;
  Drawing = 0 ;
  
  HorizontalOrVerticalCode:               // Warning - target of a goto!!!!

  Interpolate( Zgrid.x( XTracePoint), Zgrid.y( YTracePoint),
	       Zgrid.z( XTracePoint, YTracePoint),
	       Zgrid.x( XTraceSubPoint), Zgrid.y( YTraceSubPoint),
	       Zgrid.z( XTraceSubPoint, YTraceSubPoint)  ) ;

  Locate = 3*(YTracePoint-YTraceSubPoint) +
		  XTracePoint-XTraceSubPoint + 4;
      //assert( Locate >=0 && Locate <9 ); 
  
  XNext = XTraceSubPoint + XLookupTable[ Locate ];
  YNext = YTraceSubPoint + YLookupTable[ Locate ];

  // Test to see if the next point is past an edge.

  if( (XNext >= NumberOfX) || (XNext < 0) ||
      (YNext >= NumberOfY) || (YNext < 0)   ) return; 
  
  // Check - if vertical line and been contoured before - all done.

  if( (Locate == 5) && SwitchSet(XTracePoint,YTracePoint) ) return;


  if( !DiagonalTest[Locate] )
  {
  if( Zgrid.z( XNext,YNext) > ContourValue )
    { XTracePoint = XNext;
      YTracePoint = YNext; } 
    else
    { XTraceSubPoint = XNext;
      YTraceSubPoint = YNext; }
                                              goto HorizontalOrVerticalCode;  
   }
  
  // Diagonals get special treatment = the midpoint of the rectangle
  // has a midpoint which is calculated and used as a contour point.

  XMidPoint =  ( Zgrid.x( XTracePoint) + Zgrid.x(XNext) )*(float) 0.5;
  YMidPoint =  ( Zgrid.y( YTracePoint) + Zgrid.y(YNext) )*(float) 0.5;

  Locate = 3*(YTracePoint-YNext) + XTracePoint - XNext + 4;
      //assert( (Locate >= 0) && (Locate <9) );

  XMidNext = XNext + XLookupTable[Locate];
  YMidNext = YNext + YLookupTable[Locate];
  //assert( ( XMidNext >= 0) && (XMidNext < NumberOfX) );
  //assert( ( YMidNext >= 0) && (YMidNext < NumberOfY) );

  ZMidPoint = ( Zgrid.z(XTracePoint,YTracePoint) +
		Zgrid.z(XTraceSubPoint, YTraceSubPoint) +
		Zgrid.z(XNext, YNext) +
		Zgrid.z(XMidNext, YMidNext ) )*(float) 0.25;

  if( ZMidPoint > ContourValue)                  goto MidPointGTContourCode;
  // Midpoint less than contour value 
  Interpolate( Zgrid.x(XTracePoint), Zgrid.y(YTracePoint),
	       Zgrid.z(XTracePoint,YTracePoint),
	       XMidPoint, YMidPoint, ZMidPoint );

  if( Zgrid.z(XMidNext,YMidNext) <= ContourValue )

  // Turn off sharp right.... 
  { XTraceSubPoint = XMidNext;
    YTraceSubPoint = YMidNext;
                                              goto HorizontalOrVerticalCode; 
  }

  Interpolate( Zgrid.x(XMidNext), Zgrid.y(YMidNext),
	       Zgrid.z(XMidNext, YMidNext),
	       XMidPoint, YMidPoint, ZMidPoint );

  if( Zgrid.z(XNext,YNext) <= ContourValue)
  // Continue straight through.... 
  { XTracePoint = XMidNext;
    YTracePoint = YMidNext;
    XTraceSubPoint = XNext;
    YTraceSubPoint = YNext;
                                              goto HorizontalOrVerticalCode; 
  }
  // Wide left turn.
  Interpolate(Zgrid.x(XNext), Zgrid.y(YNext),
	      Zgrid.z(XNext,YNext),
	      XMidPoint, YMidPoint, ZMidPoint );

  XTracePoint = XNext;
  YTracePoint = YNext;
                                              goto HorizontalOrVerticalCode;

MidPointGTContourCode:                                  // Target of a goto!

  Interpolate( XMidPoint, YMidPoint, ZMidPoint,
	       Zgrid.x(XTraceSubPoint), Zgrid.y(YTraceSubPoint),
	       Zgrid.z(XTraceSubPoint,YTraceSubPoint) );

  // It may be a sharp left turn.
  if( Zgrid.z(XNext,YNext) > ContourValue)
  {XTracePoint = XNext;
   YTracePoint = YNext;
                                              goto HorizontalOrVerticalCode;  
  }
  // no 
  Interpolate( XMidPoint, YMidPoint, ZMidPoint,
	       Zgrid.x(XNext), Zgrid.y(YNext),
	       Zgrid.z(XNext,YNext) );
  // Continue straight through? 
  if( Zgrid.z( XMidNext,YMidNext) > ContourValue )
  // yes 
  { XTraceSubPoint = XNext;
    YTraceSubPoint = YNext;
    XTracePoint = XMidNext;
    YTracePoint = YMidNext;
                                              goto HorizontalOrVerticalCode;
   }

  // Wide right turn
  Interpolate( XMidPoint, YMidPoint, ZMidPoint,
	       Zgrid.x(XMidNext), Zgrid.y(YMidNext),
	       Zgrid.z(XMidNext,YMidNext) );

  XTraceSubPoint = XMidNext;
  YTraceSubPoint = YMidNext;
                                              goto HorizontalOrVerticalCode;

}
//**********************************************************************
//                     I n t e r p o l a t e
//**********************************************************************
static void Interpolate( float XRef, float YRef, float ZRef,
                         float XSub, float YSub, float ZSub ) 
{
 // This routine interpolates between the two points and calls to
 // plot the line tracing out the contour.

 static float Xdistance,
              Ydistance,
              temp,
              Fraction,
              XPlotLocation,
              YPlotLocation;
               
 if( ZSub < 0.0 ) { Drawing = 0; return; }// Don't contour negative areas.

 Xdistance = XRef - XSub;
 Ydistance = YRef - YSub;
 temp = ZRef - ZSub; // watch out- underflow!!!!!
 if( temp > 0.0 )    
      Fraction = (ZRef - ContourValue)/ temp ; 
 else Fraction = 0.0;
 if ( Fraction > 1.0 ) Fraction = 1.0;
 XPlotLocation = XRef - Fraction*Xdistance;
 YPlotLocation = YRef - Fraction*Ydistance;
 
 DoLineTo( XPlotLocation, YPlotLocation, Drawing );
 Drawing = 1;
 
}

//******************************************************************
//                       S w i t c h e s
//
//  Contouring routine to get and set bit switches. The purpose is
//  flag any reference point in the grid defining the surface if
//  a contour has been traced past it.
//
//********************************************************************

static unsigned char ON = 1;
static long CharPosition, BitOffset;
static unsigned char *BitArray = 0;
static unsigned long SizeOfBitArray = 0;
static const long BitsPerChar = 8 ;
static long FirstDimension = 0;

//****************************************************************
//               S w i t c h    C l e a r
//****************************************************************
void SwitchClear( int i, int j)
{
// Routine allocates space for i by j bit switches and clears
// them all to zero.

// If i and j are zero just delete the previous array of switches. 

 static long SizeNeeded;
 SizeNeeded = ((long)i*(long)j)/BitsPerChar+1;

 if( SizeNeeded <= 1 ) 
   { if (BitArray != 0 ) delete[] BitArray; 
     BitArray = 0; SizeOfBitArray = 0; 
     return; 
   } 

 FirstDimension = i;
 //assert(FirstDimension > 0 );

 if( SizeNeeded != SizeOfBitArray )
   { if( BitArray != 0 ) delete[] BitArray;
     BitArray = new unsigned char[SizeNeeded];
     //assert( BitArray != 0 );
     SizeOfBitArray = SizeNeeded;
   }

 memset( BitArray, 0, SizeOfBitArray); // Could use a loop to do this a byte at a time. 

}
//*********************************************************
//          S w i t c h   P o s n
//*********************************************************
static void SwitchPosn(int i, int j)
{
//  Calculate the location of the switch for SwitchSet and SwitchGet.

 static long BitPosition;
     BitPosition = (long)j*FirstDimension + (long)i;
     CharPosition = BitPosition/BitsPerChar;
     BitOffset = BitPosition - CharPosition*BitsPerChar;
     //assert( CharPosition <= SizeOfBitArray );
}
//*********************************************************
//            S w i t c h   S e t
//*********************************************************
int SwitchSet( int i, int j)
{
// Set's switch (i,j) on . It returns the old value of the switch.

 SwitchPosn( i, j );

 if( *(BitArray+CharPosition)&(ON<<BitOffset) ) return 1;

 *(BitArray+CharPosition) |= (ON<<BitOffset);
 return 0;

}
//***********************************************************
//             S w i t c h   G e t
//***********************************************************
int SwitchGet( int i, int j)
{
// Returns the value of switch (i,j).
 SwitchPosn( i, j );
 if( *(BitArray+CharPosition)&(ON<<BitOffset) ) return 1;
 return 0;
}
